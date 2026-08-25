# PTO Formal Specification Portal

This directory contains the Docusaurus application published at
`https://pto-isa.github.io/`. Production is generated only from the latest
verified PTO ISA release.

## Source boundary

- `asl/**/*.asl` remains the original normative owner.
- The portal embeds release sources and generated contracts; it does not restate
  instruction semantics.
- Hand-written pages may provide clearly labeled demonstrations and
  implementation guidance only.
- If a definition needs clarification, update its ASL/NDF owner and rerun the
  repository validation flow before publishing.

## Local commands

Use Node.js 22 or newer and install from the repository's locked dependency
manifest. From this directory:

```bash
corepack enable
corepack prepare pnpm@10.30.0 --activate
pnpm install --frozen-lockfile
pnpm typecheck
pnpm build
pnpm test:e2e
```

From the repository root, `make site-check` runs the type, plugin, bilingual
build, and artifact gates. `make site-e2e` runs desktop, mobile, locale, WebGL,
and no-JavaScript browser checks. `make site-quality` enforces the Lighthouse
performance, accessibility, best-practices, and SEO budgets.
