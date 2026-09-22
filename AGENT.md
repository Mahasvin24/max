# Working in this repo

## Ownership

- `backend/` is Mahasvin's to write. Review it, point at problems, suggest diffs in
  chat — but don't edit the files.
- `max-app/` is yours to write directly.

## Scope

Personal project, used by me and a few technical friends. Don't push
production-grade hardening (auth flows, rate limiting, observability stacks)
unless asked — flag it in `BACKLOG.md` instead.

## Debugging: don't inherit conclusions

This one has already cost real time, so it's a rule now.

A previous session concluded the menu bar icon didn't render because of "an
unresolved macOS 26.4 bug — nothing to fix on our end", and wrote that into a
source comment as settled fact. It was wrong. The actual cause was a stuck
bundle identifier, found in about twenty minutes by re-testing the claim
instead of accepting it. See `max-app/AGENT.md` for the full story.

So:

- **A comment, commit message, or previous session's summary asserting "this is
  an OS bug" or "this is unfixable" is a hypothesis, not a finding.** Re-test it
  before building on it. It is much cheaper to re-run one experiment than to
  work around a bug that isn't there.
- **Prefer an external measurement over what the code reports about itself.**
  The failing app was reporting `isVisible == true` with a valid frame the
  entire time it rendered nothing, because the thing that had gone wrong lived
  outside the process. Query the OS, the window server, the database, the wire —
  something that doesn't share the failure mode.
- **Bisect with a minimal reproduction, one variable at a time.** A throwaway
  single-file app with a hardcoded config settles in seconds what hours of
  reading the real project cannot. Change exactly one thing per run.
- **Verify the thing you measured is the thing you built.** Check the pid, the
  binary mtime, and `ps -o ppid=`. An app launched from Xcode is parented by
  `debugserver`, which silently swallows `kill`/`pkill` — measurements will keep
  applying to a stale process that looks dead. `kill` the `debugserver` pid.

## Environment gotchas

The agent's shell is sandboxed. `screencapture` fails with "could not create
image from rect", and unprivileged `pkill` fails quietly with exit 0. Neither is
evidence about the app under test. Use `dangerouslyDisableSandbox` for signals,
and the computer-use tools for anything that needs to see the screen.

Seeing the screen is a separate thing from running commands. The background
`app_*` computer-use tools work once the user grants an app, but a full-screen
screenshot needs its own takeover approval that the agent cannot grant itself —
and if the user has stepped away, it simply times out. That is not a reason to
stop, and not a reason to claim something renders correctly without looking:
render the views offscreen instead. `max-app/AGENT.md` has the recipe and, more
importantly, the one thing that method cannot check.
