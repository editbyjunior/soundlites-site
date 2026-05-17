# Repo Operating Guide

This repo follows Junior's Codex dev protocol.

## Source Of Truth
- Read this file, `README.md`, CI workflows, env examples, and deploy docs before editing.
- Preserve the current product/design intent unless Junior asks for a rethink.
- Do not revert unrelated dirty changes.

## Work Tracking
- If Junior provides Monday.com, GitHub, or Linear links, verify the live targets before writing to them.
- Connect repo work back to the supplied tracking objects in the plan and final handoff.
- Do not create or edit remote/public objects without a clear target and permission.

## Quality Gate
- Run the strongest practical checks before calling code work done.
- Preferred order: format check, lint, typecheck, tests, build, dependency audit, secrets scan.
- Use `codex-quality-gate` from the repo root when practical.
- If checks are missing, state the gap and recommend the repo-local script or CI addition.

## Security
- Never commit secrets, private keys, API tokens, credentials, `.env` files, or production exports.
- Use `.env.example` for documented variables.
- Run gitleaks or the configured secrets scan before handoff when code/config changes touch env, auth, deploy, or integrations.

## Handoff
- Close with changed paths, verification evidence, remaining gaps, and whether tracking links were updated or intentionally left untouched.
