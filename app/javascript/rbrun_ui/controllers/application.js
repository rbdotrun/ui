// Engine-local Stimulus application. Separate from any Stimulus
// instance the host may have running on its own pages — engine pages
// load this one via the engine layout, host pages load the host's.
//
// Identifiers registered against this app namespace under
// `rbrun-ui--<name>` (see ./loader.js). The host's Stimulus app
// never sees these identifiers and vice versa, so there are zero
// collision rules to remember.
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.RbrunUiStimulus = application

export { application }
