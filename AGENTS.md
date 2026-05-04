Quick, high-signal hints for agents working in this repo

Core facts
- Node required: >=22.0.0 (package.json "engines"). Many tools and the bundle target ESM; use Node 22+.
- Primary source language: ReScript (files under src/*.res, src/*.resi). Compiled-in-source outputs use the suffix .res.mjs (see rescript.json).

What to run (exact)
- Build ReScript sources: npm run res:build  (runs the `rescript` tool / compiles .res -> .res.mjs)
- Bundle for runtime (produces dist/main.mjs): npm run bundle  (runs `rolldown -c` using rolldown.config.mjs)
- Start the app (after bundle): npm run start  (runs `node dist/main.mjs`)
- Run tests (ReScript test runner): npm run res:test  (tests expect compilation first; if in doubt run res:build then res:test)
- Watch ReScript during development: npm run res:dev
- Serve docs locally: npm run docs

Important ordering and gotchas
- Do NOT trust npm run build — it runs `tsdown` (TypeScript legacy). The current ReScript flow is: npm run res:build && npm run bundle. If you only run `npm run build` the bundle/start will likely fail or be stale.
- rescript.json has "namespace": true. Do not remove or change this lightly — module names will gain/lose the Chartex__ prefix and break imports/tests.
- rescript.json uses in-source compilation and suffix ".res.mjs". The committed .res.mjs files in src/ are generated artifacts. Edit the .res source files, not the compiled .res.mjs files; run npm run res:build to regenerate.
- rolldown.config.mjs expects entry src/index.mjs and emits dist/main.mjs. The bundle step depends on compiled .res.mjs modules being present under src/ (rescript build produces those).
- The bundle excludes @rescript/runtime (external). @rescript/runtime is a dependency and must be present in node_modules during runtime and publishing.

Quick file references (what I checked)
- package.json — scripts and engines
- rescript.json — namespace, in-source, suffix
- rolldown.config.mjs — bundle input/output and externals
- tsdown.config.mjs — legacy TypeScript bundler (leftover; used by npm run build)

If something is failing
- If start fails with missing dist/*: run npm run res:build && npm run bundle.
- If imports resolve differently after changing rescript.json: run a full rescript build and re-bundle; expect module name changes.

If you're making changes to build config or publishing
- The package.json `files` array includes only dist — ensure your bundle produces the expected files before publishing.

Keep it minimal: prefer executable sources of truth (package.json, rescript.json, rolldown.config.mjs) over docs.
