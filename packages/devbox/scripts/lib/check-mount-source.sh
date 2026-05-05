#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/lib/check-mount-source.sh
#
# Sourced by every host wrapper that does `docker exec` against the
# running keel-devbox container. Verifies the running container's
# /workspace/${REPO_NAME} bind-mount source matches the current
# invocation's MAIN_REPO. Defends against the worktree-A-started-the-
# container-then-operator-invokes-from-worktree-B race: `docker compose
# up -d` is a no-op when the container is already running, so a stale
# bind-source would silently land docker-exec into the wrong host repo.
#
# Exit code 12 (extends the SC-5 schema documented in
# packages/devbox/README.md): "bind-mount mismatch — run pnpm
# devbox:restart". Operator-actionable; the message tells exactly what to
# do.
#
# Both running_source and MAIN_REPO are normalised through `pwd -P` so
# macOS /var → /private/var symlinks compare cleanly. Empty
# running_source means the container is not running (or the mount with
# the expected destination is absent); silent return so downstream
# wrappers can decide whether to bring the container up themselves.
#
# Caller MUST export MAIN_REPO + REPO_NAME + CONTAINER_NAME before
# invoking check_mount_source. The resolve_main_repo_and_workdir
# function in lib/main-repo-resolver.sh exports the first two.
# ---------------------------------------------------------------------------

check_mount_source() {
	local target="/workspace/${REPO_NAME}"
	local running_source
	running_source="$(docker inspect "${CONTAINER_NAME}" \
		--format "{{ range .Mounts }}{{ if eq .Destination \"${target}\" }}{{ .Source }}{{ end }}{{ end }}" \
		2>/dev/null || true)"
	if [[ -z "$running_source" ]]; then
		# Container not running OR mount not yet realised — let downstream
		# wrappers handle (typically by calling start.sh which will bring
		# it up with the correct source).
		return 0
	fi
	local running_real main_real
	running_real="$(cd "$running_source" 2>/dev/null && pwd -P || echo "$running_source")"
	main_real="$(cd "$MAIN_REPO" && pwd -P)"
	if [[ "$running_real" != "$main_real" ]]; then
		printf 'check-mount-source: FATAL: container %s is bound to %s\n' "$CONTAINER_NAME" "$running_source" >&2
		printf 'check-mount-source: but invocation is from main repo %s\n' "$MAIN_REPO" >&2
		printf 'check-mount-source: remediate: pnpm devbox:restart\n' >&2
		printf 'check-mount-source: (compose treats running containers as authoritative;\n' >&2
		printf 'check-mount-source:  a fresh up -d skips bind-source changes without an explicit down)\n' >&2
		exit 12
	fi
}
