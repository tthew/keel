# packages/devbox/scripts/lib/compose-args.sh — Story 2.12 PATCH-5 (from
# iter-271 /bmad-code-review finding; landed iter-276)
#
# Populate the `COMPOSE_ARGS` bash array with the `-f` flags for a
# `docker compose` invocation, composing the base `docker-compose.yml`
# with the opt-in `docker-compose.ssh.yml` (Story 2.12) when
# `KEEL_DEVBOX_SSH` is resolved-true.
#
# Why an array and not the inline `${VAR:+-f "${VAR}"}` idiom:
# the inline form sits unquoted at the outer level (it must — an empty
# expansion needs to elide cleanly, a quoted empty string would pass an
# extra empty argv to `docker compose`). Bash's `${VAR:+...}`
# alternate-value expansion produces a STRING which the shell re-
# tokenises by word-splitting BEFORE the embedded double-quote chars
# are re-parsed (they become literal `"` characters post-expansion, not
# quoting chars). Under a fork whose repo path contains whitespace
# (`/Users/Some User/projects/ralph-bmad`, `~/My Code/...`), the single
# path `/Users/Some User/.../docker-compose.ssh.yml` word-splits into
# separate argv elements (`/Users/Some` and `User/.../docker-compose.ssh.yml`)
# and `docker compose` fails with "no such file or directory". ShellCheck
# SC2086 flags the inline idiom; the array idiom is the canonical
# safer form — each element is passed verbatim to the exec'd program.
#
# Hazard class note: this is DISTINCT from RALPH.md 2026-04-21 AR-9
# (`for x in $(...)` iterable word-splitting on IFS). AR-9 is about
# command-substitution output splitting; this is about embedded-quote-
# under-unquoted-alt-expansion re-tokenisation. Different mechanism,
# different mitigation — the inline `${VAR:+...}` idiom does NOT
# mitigate the iter-271 PATCH-5 hazard.
#
# Contract:
#   Caller MUST have sourced `lib/main-repo-resolver.sh` AND invoked
#   `resolve_ssh_state()` before calling `resolve_compose_args()` (the
#   function reads `KEEL_DEVBOX_COMPOSE_FILE_SSH` which the resolver
#   exports). The caller MUST have set `COMPOSE_FILE` to the absolute
#   path of `docker-compose.yml`.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
#   resolve_ssh_state
#   # shellcheck source=lib/compose-args.sh
#   source "${SCRIPT_DIR}/lib/compose-args.sh"
#   resolve_compose_args
#   exec docker compose "${COMPOSE_ARGS[@]}" build devbox
#
# See docs/invariants/devbox-ssh.md § Compose-CLI idiom for the
# authoritative caller wiring.

resolve_compose_args() {
	COMPOSE_ARGS=(-f "${COMPOSE_FILE}")
	if [[ -n "${KEEL_DEVBOX_COMPOSE_FILE_SSH:-}" ]]; then
		COMPOSE_ARGS+=(-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}")
	fi
}
