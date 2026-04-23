#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/lib/main-repo-resolver.sh
#
# Sourced by every host wrapper that interacts with the keel-devbox
# container. Computes three values that pin the host ↔ container path
# isomorphism:
#
#   WORKTREE_ROOT     absolute, symlink-resolved path to the git working
#                     tree the operator invoked from (= the WORKTREE root
#                     when invoked from a worktree, or the main repo root
#                     when invoked from main). Computed via `git rev-parse
#                     --show-toplevel`. This path is what compose binds
#                     into the container because it contains the devbox
#                     files (Dockerfile, compose, scripts, whitelist) that
#                     may not exist on the main repo's current branch.
#
#   REPO_NAME         container-side subdir name under /workspace/.
#                     Defaults to $(basename <main-repo-root>), NOT
#                     $(basename WORKTREE_ROOT) — we want the container
#                     path to reflect the fork identity, not the worktree
#                     name. A worktree "ralph" under main repo "my-fork"
#                     mounts at /workspace/my-fork, not /workspace/ralph.
#                     Operators override via KEEL_DEVBOX_REPO_NAME.
#
#   CONTAINER_WORKDIR mirrors the host invocation cwd relative to
#                     WORKTREE_ROOT. `pnpm` from <root>/packages/web lands
#                     at /workspace/${REPO_NAME}/packages/web.
#
# Three-tier fallback for resolution (matches env-check.sh:38-45):
#   1. git rev-parse (worktree-aware)
#   2. KEEL_DEVBOX_REPO_ROOT env override (operator escape hatch)
#   3. ${SCRIPT_DIR}/../../.. (tarball forks without .git)
#
# `pwd -P` resolves macOS /var → /private/var so docker-inspect Source
# values compare cleanly under the mount-source check (see
# check-mount-source.sh).
#
# Historical note (iter-239): an earlier design bound the *main repo*
# (not the worktree) to reflect the full host directory layout in the
# container. That broke at runtime: if the main repo is on a different
# branch than the worktree (common in this project's Ralph-loop + epic-
# branch workflow), the main repo's working tree may not contain the
# devbox scripts → entrypoint fails `start-egress.sh not executable`.
# Binding the worktree is simpler and always works regardless of main-
# repo branch state.
# ---------------------------------------------------------------------------

# Defensive unset — every host wrapper already does this independently
# (per Story 2.6 AI-8 + AI-12), but belt-and-braces here ensures the
# resolver never picks up an operator-set COMPOSE_PROJECT_NAME that would
# misalign downstream `docker compose` invocations with the
# `name: keel-devbox` declaration in docker-compose.yml.
unset COMPOSE_PROJECT_NAME

resolve_main_repo_and_workdir() {
	local git_common_dir main_repo_root
	if WORKTREE_ROOT="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
		WORKTREE_ROOT="$(cd "$WORKTREE_ROOT" && pwd -P)"
		# git --git-common-dir returns the main-repo .git path from a
		# worktree; dirname yields the main repo root (used for REPO_NAME).
		git_common_dir="$(git -C "$PWD" rev-parse --git-common-dir 2>/dev/null)"
		main_repo_root="$(cd "$(dirname "$git_common_dir")" && pwd -P)"
	elif [[ -n "${KEEL_DEVBOX_REPO_ROOT:-}" ]]; then
		WORKTREE_ROOT="$(cd "${KEEL_DEVBOX_REPO_ROOT}" && pwd -P)"
		main_repo_root="$WORKTREE_ROOT"
	elif [[ -n "${SCRIPT_DIR:-}" ]]; then
		WORKTREE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd -P)"
		main_repo_root="$WORKTREE_ROOT"
	else
		printf 'main-repo-resolver: FATAL: cannot resolve worktree (no git, no KEEL_DEVBOX_REPO_ROOT, no SCRIPT_DIR)\n' >&2
		return 1
	fi
	export WORKTREE_ROOT
	# MAIN_REPO kept as an alias for backwards-compat with check-mount-
	# source.sh and any downstream wrapper scripts — points at the bind
	# source, which under this design is the worktree root.
	MAIN_REPO="$WORKTREE_ROOT"
	export MAIN_REPO

	REPO_NAME="${KEEL_DEVBOX_REPO_NAME:-$(basename "$main_repo_root")}"
	export REPO_NAME

	local pwd_real
	pwd_real="$(cd "$PWD" && pwd -P)"
	case "$pwd_real" in
		"$WORKTREE_ROOT")
			CONTAINER_WORKDIR="/workspace/$REPO_NAME"
			;;
		"$WORKTREE_ROOT"/*)
			CONTAINER_WORKDIR="/workspace/$REPO_NAME/${pwd_real#$WORKTREE_ROOT/}"
			;;
		*)
			printf 'main-repo-resolver: WARNING: cwd %s not in worktree %s; landing at /workspace/%s\n' \
				"$pwd_real" "$WORKTREE_ROOT" "$REPO_NAME" >&2
			CONTAINER_WORKDIR="/workspace/$REPO_NAME"
			;;
	esac
	export CONTAINER_WORKDIR
}
