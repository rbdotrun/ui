// Engine's JS entry point. Loaded by the engine layout via
// `<%= javascript_importmap_tags "rbrun_ui/application", importmap: RbrunUi.importmap %>`.
//
// Single responsibility: boot the engine's Stimulus app + register
// every component sidecar. No host JS runs here; engine routes have
// their own JS module graph wired through `RbrunUi.importmap`.
import "@hotwired/turbo-rails"
import "rbrun_ui/controllers"
