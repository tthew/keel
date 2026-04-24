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
# Mode-specific state (Story 2.11). `resolve_mode_specific_state()` is a
# sibling function invoked AFTER `resolve_main_repo_and_workdir()` by every
# host-side shim. It reads `KEEL_DEVBOX_SHARED` from the process env (set
# by `.envrc` via direnv) and branches resolver state between two modes:
#
#   per-fork mode (default; KEEL_DEVBOX_SHARED != "true"):
#     WORKTREE_ROOT / MAIN_REPO / REPO_NAME / CONTAINER_WORKDIR =
#       whatever resolve_main_repo_and_workdir() computed.
#     KEEL_DEVBOX_COMPOSE_PROJECT         = "keel-devbox"
#     KEEL_DEVBOX_CONTAINER_NAME_RESOLVED = "${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
#                                           (preserves Story 2.1's operator
#                                           override path).
#
#   shared mode (KEEL_DEVBOX_SHARED = "true" after case-fold):
#     WORKTREE_ROOT / MAIN_REPO           = $(dirname "$MAIN_REPO") — the
#                                           parent directory of the fork root.
#     REPO_NAME                           = basename of the parent dir —
#                                           shared mode HARDCODES this;
#                                           operator's KEEL_DEVBOX_REPO_NAME
#                                           setting is intentionally ignored
#                                           so fork A and fork B resolve to
#                                           the SAME /workspace/<parent>/
#                                           bind target (AC 2; iter-261
#                                           PATCH-1 extension of SC-4).
#     CONTAINER_WORKDIR                   = re-derived against the new
#                                           WORKTREE_ROOT so the caller lands
#                                           at /workspace/<parent>/<fork>/
#                                           <relative-subpath> (SC-12).
#     KEEL_DEVBOX_COMPOSE_PROJECT         = "keel-devbox-shared"
#     KEEL_DEVBOX_CONTAINER_NAME_RESOLVED = "keel-devbox-shared" — shared mode
#                                           HARDCODES this; operator's
#                                           KEEL_DEVBOX_CONTAINER_NAME setting
#                                           is intentionally ignored so fork A
#                                           and fork B attach to the SAME
#                                           container (AC 2).
#
# Normalisation: `${KEEL_DEVBOX_SHARED:-false}` is lowercased and compared
# to the literal string "true". Anything else (false, 0, no, empty, unset)
# resolves to per-fork mode. `TRUE` / `True` / `true` all route to shared
# (operator-typo-tolerant); everything else fails safely to per-fork.
#
# See `docs/invariants/devbox-mode.md` (INV-devbox-mode) for the full
# two-mode contract + mid-use-flip orphan-container warning semantics.
#
# Opt-in sshd state (Story 2.12). `resolve_ssh_state()` is a sibling function
# invoked AFTER `resolve_mode_specific_state()` by every host-side shim that
# composes the `docker compose -f` CLI. It reads `KEEL_DEVBOX_SSH` from the
# process env (set by `.envrc` via direnv), normalises strictly to the literal
# `true` (case-folded; any other value — `false`/`yes`/`1`/`on`/empty/unset —
# fail-closes to no-SSH), and exports two values:
#
#   KEEL_DEVBOX_SSH_RESOLVED        = "true" | "false"  (canonical normalised)
#   KEEL_DEVBOX_COMPOSE_FILE_SSH    = ""                 when no-SSH, OR
#                                   = "${DEVBOX_DIR}/docker-compose.ssh.yml"
#                                                        when opt-in SSH.
#
# Caller wiring idiom (Story 2.12 PATCH-5, iter-276): every shim that
# invokes `docker compose` sources `lib/compose-args.sh` after this
# resolver and calls `resolve_compose_args` to populate the
# `COMPOSE_ARGS` bash array, then invokes `docker compose
# "${COMPOSE_ARGS[@]}" <subcommand>`. Superseded inline form
# `${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"}`
# was unquoted at the outer level and word-split forks whose repo path
# contained whitespace. See `lib/compose-args.sh` header for the
# hazard-class analysis (distinct from AR-9). Shared mode (Story 2.11)
# does NOT change this — the override composes regardless of mode
# (sshd is per-container, not per-mode).
#
# See `docs/invariants/devbox-ssh.md` (INV-devbox-ssh) for the full contract
# (loopback-bound port publication + opt-in sshd + pubkey-only + named-volume
# persistence).
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

resolve_mode_specific_state() {
	# Read + normalise the mode signal. Default-substitution keeps this
	# safe under `set -u` (every shim enforces it). Non-`true` values
	# fail-closed to per-fork — the safe posture — per § Dev Notes
	# § `set -euo pipefail` discipline.
	local shared
	shared="$(echo "${KEEL_DEVBOX_SHARED:-false}" | tr '[:upper:]' '[:lower:]')"

	if [[ "$shared" != "true" ]]; then
		# Per-fork mode (default). WORKTREE_ROOT / MAIN_REPO / REPO_NAME /
		# CONTAINER_WORKDIR stay as resolve_main_repo_and_workdir() set them.
		KEEL_DEVBOX_COMPOSE_PROJECT="keel-devbox"
		KEEL_DEVBOX_CONTAINER_NAME_RESOLVED="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
		export KEEL_DEVBOX_COMPOSE_PROJECT KEEL_DEVBOX_CONTAINER_NAME_RESOLVED
		return 0
	fi

	# Shared mode. Flip WORKTREE_ROOT / MAIN_REPO / REPO_NAME to the parent
	# directory; re-derive CONTAINER_WORKDIR against the new WORKTREE_ROOT.
	local shared_parent shared_parent_name
	shared_parent="$(dirname "$MAIN_REPO")"
	shared_parent_name="$(basename "$shared_parent")"
	MAIN_REPO="$shared_parent"
	WORKTREE_ROOT="$shared_parent"
	# Shared mode hardcodes REPO_NAME regardless of operator KEEL_DEVBOX_REPO_NAME —
	# AC 2 requires fork A and fork B to resolve to the SAME /workspace/<parent>/
	# bind target; a per-fork REPO_NAME override would silently produce divergent
	# container paths (second fork's `docker exec -w` would hit ENOENT).
	REPO_NAME="$shared_parent_name"
	export MAIN_REPO WORKTREE_ROOT REPO_NAME

	# Re-derive CONTAINER_WORKDIR against the NEW WORKTREE_ROOT. Do NOT
	# call back into resolve_main_repo_and_workdir — that would overwrite
	# MAIN_REPO back to the per-fork value. Inline case-block mirrors
	# resolve_main_repo_and_workdir's L86-98 shape.
	local pwd_real
	pwd_real="$(cd "$PWD" && pwd -P)"
	case "$pwd_real" in
		"$WORKTREE_ROOT")
			CONTAINER_WORKDIR="/workspace/$REPO_NAME"
			;;
		"$WORKTREE_ROOT"/*)
			CONTAINER_WORKDIR="/workspace/$REPO_NAME/${pwd_real#"$WORKTREE_ROOT"/}"
			;;
		# Else: leave CONTAINER_WORKDIR at the per-fork value from the
		# prior resolver run — safe default when caller's $PWD is outside
		# the shared-mode parent (rare edge case).
	esac
	export CONTAINER_WORKDIR

	# Shared mode hardcodes the container name regardless of operator
	# KEEL_DEVBOX_CONTAINER_NAME — AC 2 requires fork A and fork B to
	# attach to the SAME container; an operator-specific override would
	# silently break that.
	KEEL_DEVBOX_COMPOSE_PROJECT="keel-devbox-shared"
	KEEL_DEVBOX_CONTAINER_NAME_RESOLVED="keel-devbox-shared"
	export KEEL_DEVBOX_COMPOSE_PROJECT KEEL_DEVBOX_CONTAINER_NAME_RESOLVED
}

resolve_ssh_state() {
	# Story 2.12: opt-in sshd resolver. Strict `true`-only normalisation per
	# SC-2 mirrors Story 2.11 `resolve_mode_specific_state()` idiom at :152 —
	# forks MAY NOT extend the accepted-signal set. Any other value
	# (`false`/`yes`/`1`/`on`/empty/unset/garbage) fail-closes to no-SSH.
	local ssh
	ssh="$(echo "${KEEL_DEVBOX_SSH:-false}" | tr '[:upper:]' '[:lower:]')"

	if [[ "$ssh" != "true" ]]; then
		KEEL_DEVBOX_SSH_RESOLVED="false"
		KEEL_DEVBOX_COMPOSE_FILE_SSH=""
		export KEEL_DEVBOX_SSH_RESOLVED KEEL_DEVBOX_COMPOSE_FILE_SSH
		return 0
	fi

	# Compute the override-file absolute path from the lib's own location
	# (packages/devbox/scripts/lib/main-repo-resolver.sh → ../.. = packages/
	# devbox/). Keeps the resolver self-contained and independent of caller-
	# set DEVBOX_DIR, while still honouring the source-of-truth layout
	# contract.
	local lib_dir devbox_dir
	lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
	devbox_dir="$(cd "${lib_dir}/../.." && pwd -P)"

	KEEL_DEVBOX_SSH_RESOLVED="true"
	KEEL_DEVBOX_COMPOSE_FILE_SSH="${devbox_dir}/docker-compose.ssh.yml"
	export KEEL_DEVBOX_SSH_RESOLVED KEEL_DEVBOX_COMPOSE_FILE_SSH
}
