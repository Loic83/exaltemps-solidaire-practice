# Architecture Decision Record (ADR)

This file is the **single log** of the project's architecture decisions (framework/library choices, structural patterns, trade-offs with lasting impact).

## Why this file

- **Memory of the "why"**: the code shows *what*, the Git history shows *when*, but neither explains why one option was chosen over another. This file fills that gap.
- **Avoid re-litigating the same debates**: before any proposal with architectural impact, this file must be consulted so as not to contradict or silently redo a decision that's already been made.
- **Onboarding**: anyone (human or AI agent) joining the project can quickly understand the structuring choices and their trade-offs without having to ask the original authors.
- **Traceability of trade-offs**: each entry documents the alternatives considered and the consequences accepted, making it possible to judge later whether a decision should be revisited with full knowledge of the facts.

## Usage rules

- **Append-only**: this file is a chronological log, not a document to rewrite. New entries are added; existing entries are not modified.
- **One entry per structuring decision**, with at minimum:
  - Date
  - Decision (what was chosen)
  - Context / problem being solved
  - Alternatives considered
  - Consequences / trade-offs accepted
- If a past decision needs to be revisited, the new entry must say so explicitly rather than ignoring it.

---

## Decision log

### 2026-09-21 — Testing stack: Vitest + React Testing Library, Playwright for e2e later

- **Decision**: Adopt Vitest + React Testing Library as the standard for unit/component/integration tests, and Playwright for end-to-end tests once critical user flows exist. Documented in [docs/testing-guidelines.md](docs/testing-guidelines.md).
- **Context**: `docs/testing-guidelines.md` was referenced by CLAUDE.md but did not exist, and no test tooling was installed in the project (fresh Next.js 16 scaffold, no `test` script, no test dependencies).
- **Alternatives considered**:
  - Jest — more established with React historically, but slower and needs more config for ESM/TypeScript with Next.js 16; Vitest has largely superseded it for new projects.
  - Cypress for e2e — viable, but Playwright has better multi-browser support and faster CI execution.
- **Consequences / trade-offs accepted**: Tooling (Vitest, RTL, config, `test` script) is not yet installed — this is deliberately left as a separate, explicit task rather than bundled with the guidelines doc, to keep changes minimal and scoped. Playwright is deferred until there is an actual critical user flow worth covering, to avoid testing infrastructure ahead of real product surface.

### 2026-09-21 — Vitest + React Testing Library tooling installed

- **Decision**: Install and wire up the tooling decided above: `vitest`, `@vitejs/plugin-react`, `jsdom`, `@testing-library/react`, `@testing-library/jest-dom`, `@testing-library/user-event` as dev dependencies; `vitest.config.mts` (jsdom environment, native Vite tsconfig-paths resolution) and `vitest.setup.ts`; `npm test` and `npm run test:watch` scripts.
- **Context**: Follow-up to the same-day decision above — the guidelines existed but tooling did not. `@types/node` had to be bumped from `^20` to `^24` in `package.json` because Vitest 5 requires `@types/node` `^22 || >=24` as a peer, and the local Node runtime is v24.
- **Alternatives considered**: Used `vite-tsconfig-paths` plugin initially, then switched to Vite's native `resolve.tsconfigPaths: true` (Vite now supports this natively, removing an extra dependency and a deprecation warning).
- **Consequences / trade-offs accepted**: `@types/node` moving to `^24` narrows the supported Node range for type-checking to newer Node versions — acceptable since the local/dev runtime is already v24. Verified `npm run lint`, `npm run build`, and `npm test` all pass after the change.

### 2026-10-25 — Playwright installed for the pitch demo (`npm run demo`)

- **Decision**: Install `@playwright/test` as a dev dependency now, with `playwright.config.ts` (Chromium only, `baseURL` read from `BASE_URL`, default `http://localhost:3000`), a `demo` script (`playwright test e2e/demo.spec.ts --headed`) and a starter `e2e/demo.spec.ts` with one step (open the application). This revisits the 2026-09-21 decision to defer Playwright until critical user flows exist.
- **Context**: The hackathon harness (README, `HARNAIS.md`, `/iteration`) presents `npm run demo` as the pitch demo, but the script did not exist; the review of PR #1 (point S5) flagged it. Each hackathon iteration adds its steps to the demo, so it must exist from the start.
- **Alternatives considered**: Leave the installation to the agent during the first iteration, as `/iteration` step 4 allows — rejected because `npm run demo` would not exist before then and the install would eat into a 10-minute coding budget.
- **Consequences / trade-offs accepted**: One more dev dependency, and each workstation must run `npx playwright install chromium` (documented in the README). The demo is not a test suite: Vitest keeps excluding `e2e/**`. `--headed` needs a display; on a VM without one, the demo must be run without `--headed`. Verified: `npm run demo` passes against `next dev` on localhost.

### 2026-10-25 — Practice repository: same harness as the hackathon, offline simulations

- **Decision**: The practice repository copies the hackathon repository (`exaltemps-solidaire`, `main` at `a834522`) as is, and only adds what a one-hour offline workshop needs: the demo handover `exemples/passation-DEMO01/` (copied into `passation/` by `recuperer-passation.sh DEMO01`), a simulated PM Lab signal written to `.iterations/signaux.log` for `DEMO01`, `scripts/publier.sh` (build + `next start` in the background on `PORT`, `URL_PUBLIQUE=http://localhost:3000`), `scripts/verifier-poste.sh`, and no `git push` during the workshop.
- **Context**: The workshop onboards participants to the harness before part 2 of the hackathon. They must go through the same commands, rules and checks, without a PM Lab key, a real team code or a public URL, and without pushing to a repository shared by all participants.
- **Alternatives considered**: Keep the previous "palier 1" workshop (AGENTS.md, no harness) — rejected, it does not prepare for part 2. A starter already compliant with the deployability contract — rejected to keep the exact part 2 path (iteration 1 lays the skeleton).
- **Consequences / trade-offs accepted**: Harness changes made in the hackathon repository must be copied here by hand. The publication mechanism exists only in the workshop; the hackathon still has none.
