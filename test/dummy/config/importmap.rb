# Dummy app's importmap. The engine's importmap is merged in
# automatically (see lib/rbrun_ui/engine.rb — `app.config.importmap.paths`),
# so component sidecars and floating-ui resolve without any manual pin
# here.

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
