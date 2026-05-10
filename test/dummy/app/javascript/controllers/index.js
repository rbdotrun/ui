import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { eagerLoadComponentSidecars } from "rbrun_ui/sidecar_loading"

eagerLoadControllersFrom("controllers", application)
eagerLoadComponentSidecars(application)
