# Engine importmap. Drawn into `RbrunUi.importmap` — a separate
# `Importmap::Map` instance from `Rails.application.importmap` (see
# `lib/rbrun_ui/engine.rb` for the wiring). The engine layout renders
# this importmap explicitly via:
#
#     <%= javascript_importmap_tags "rbrun_ui/application",
#                                    importmap: RbrunUi.importmap %>
#
# So the engine's JS module graph is fully isolated from the host's:
# the host could have its own conflicting pins (`@hotwired/stimulus`
# pinned to a different version, a different `@floating-ui/dom`, etc.)
# and this engine still resolves its dependencies correctly.

# ─── Hotwire core ──────────────────────────────────────────────────
# Pinned to the local versions shipped with the host's stimulus-rails /
# turbo-rails gems (the engine's `assets.paths` add these directories
# transitively because tailwindcss-rails / stimulus-rails / turbo-rails
# Railties register them).
pin "@hotwired/turbo-rails",       to: "turbo.min.js"
pin "@hotwired/stimulus",          to: "stimulus.min.js"
pin "@hotwired/stimulus-loading",  to: "stimulus-loading.js"

# ─── Engine entry points ───────────────────────────────────────────
pin "rbrun_ui/application",        preload: true
pin "rbrun_ui/controllers",        to: "rbrun_ui/controllers/index.js"
pin "rbrun_ui/controllers/application"
pin "rbrun_ui/controllers/loader"
pin "rbrun_ui/controllers/overlay_panel"

# ─── Component sidecars ────────────────────────────────────────────
# Walks `app/components/rbrun_ui/ui/<name>/controller.js` and pins each
# under `rbrun_ui/components/ui/<name>/controller`. The loader at
# `app/javascript/rbrun_ui/controllers/loader.js` recognises this key
# pattern and registers the default export under Stimulus identifier
# `rbrun-ui--<name>`. New components are picked up automatically — no
# manual edit to this file when you add a sidecar.
#
# `under: "rbrun_ui/components/ui"` strips the inner `ui/` path
# segment so the resulting Stimulus identifier is short and human-typeable:
#   File: app/components/rbrun_ui/ui/button/controller.js
#   Pin:  rbrun_ui/components/ui/button/controller
#   Asset path (via `to:`): rbrun_ui/ui/button/controller.js
#   Loader identifier: rbrun-ui--button
#
# `to: "rbrun_ui/ui"` rewrites the asset prefix so Propshaft resolves
# the file via `app/components` (the engine's asset root) +
# `rbrun_ui/ui/<name>/controller.js`. Without `to:`, the asset path
# would default to `<name>/controller.js`, which Propshaft can't find.
pin_all_from RbrunUi::Engine.root.join("app/components/rbrun_ui/ui"),
             under: "rbrun_ui/components/ui",
             to:    "rbrun_ui/ui"

# ─── External — Floating UI from CDN ───────────────────────────────
# CDN'd to avoid vendoring 4 minified files into the gem. The engine
# is the only consumer; if the host needs Floating UI it pins its own.
pin "@floating-ui/dom",       to: "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.7.4/+esm"
pin "@floating-ui/core",      to: "https://cdn.jsdelivr.net/npm/@floating-ui/core@1.6.9/+esm"
pin "@floating-ui/utils",     to: "https://cdn.jsdelivr.net/npm/@floating-ui/utils@0.3.0/+esm"
pin "@floating-ui/utils/dom", to: "https://cdn.jsdelivr.net/npm/@floating-ui/utils@0.3.0/dom/+esm"
