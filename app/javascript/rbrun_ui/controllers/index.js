// Engine controller loader. Walks the engine importmap for every entry
// matching `rbrun_ui/components/<...>/controller`, dynamically imports
// the module, and registers the default export against the engine's
// Stimulus application under a `rbrun-ui--<name>` identifier derived
// from the path. See ./loader.js for the derivation rules.
//
// New components are picked up automatically — drop a `controller.js`
// next to a `component.rb`, the importmap pin via `pin_all_from` lands,
// the loader registers it on next page load. No registration boilerplate.
import { application } from "rbrun_ui/controllers/application"
import { eagerLoadEngineControllersFrom } from "rbrun_ui/controllers/loader"

eagerLoadEngineControllersFrom("rbrun_ui/components/ui", application)
