// Importmap-driven Stimulus controller loader for the engine.
//
// Adapted from aeno's loader (https://github.com/getnvoi/ui). The key
// trick: instead of relying on `@hotwired/stimulus-loading`'s standard
// `*_controller.js` filename convention, we walk the importmap for any
// entry matching `<under>/<...>/controller` and derive a Stimulus
// identifier from the remaining path segments.
//
// Why a custom loader: our component sidecars live at
// `app/components/rbrun_ui/ui/<name>/controller.js` — bare
// `controller.js`, with the parent directory naming the controller.
// The standard Stimulus loader expects `*_controller.js` and skips
// these. The `pin_all_from(...)` in `config/importmap.rb` produces
// importmap keys like `rbrun_ui/components/ui/button/controller`
// which this loader recognises and registers as `rbrun-ui--button`.
//
// Identifier derivation:
//   path = "rbrun_ui/components/ui/button/controller"
//   under = "rbrun_ui/components/ui"
//   namespace = "rbrun-ui" (from "rbrun_ui", `_` → `-`)
//   relative = "button/controller" → strip "/controller" → "button"
//   identifier = "rbrun-ui--button"
//
// Multi-segment names (e.g. "table_row" → "table-row") work because
// `_` → `-` is applied last; nested directories ("foo/bar") become
// `--`-separated identifiers.

function importmapImports() {
  const node = document.querySelector("script[type=importmap]")
  return node ? JSON.parse(node.textContent).imports : {}
}

function derivedIdentifier(path, under) {
  const namespace = under.split("/")[0].replace(/_/g, "-")
  const withoutPrefix = path.replace(new RegExp(`^${under}/`), "")

  let base
  if (withoutPrefix.endsWith("/controller")) {
    base = withoutPrefix.slice(0, -"/controller".length)
  } else if (withoutPrefix.endsWith("_controller")) {
    base = withoutPrefix.slice(0, -"_controller".length)
  } else {
    return null
  }

  return `${namespace}--${base.replace(/\//g, "--").replace(/_/g, "-")}`
}

export function eagerLoadEngineControllersFrom(under, application) {
  const paths = Object.keys(importmapImports()).filter((path) =>
    path.startsWith(`${under}/`),
  )

  paths.forEach((path) => {
    const identifier = derivedIdentifier(path, under)
    if (!identifier) return

    import(path)
      .then((module) => {
        if (module.default) {
          application.register(identifier, module.default)
        }
      })
      .catch((error) => {
        console.error(`Failed to load engine controller ${identifier} (${path}):`, error)
      })
  })
}
