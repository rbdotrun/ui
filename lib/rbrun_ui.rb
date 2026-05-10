require "rbrun_ui/version"
# Pull in the runtime dependencies our components reference inside their
# class bodies (style DSL, Tailwind class de-dup, lucide_icon view
# helper). The engine doesn't get a chance to call `Bundler.require` —
# host apps may use any of vanilla Bundler.require, manual requires, or
# Zeitwerk-only autoloading — so we require explicitly here.
require "view_component"
require "view_component_contrib"
require "view_component_contrib/base"
require "view_component_contrib/style_variants"
require "dry/initializer"
require "tailwind_merge"
require "lucide-rails" # registers the `lucide_icon` ActionView helper via Railtie

require "rbrun_ui/engine"

# RbrunUi — a Rails Engine that ships a small, opinionated set of
# ViewComponents (button, dialog, drawer, popover, select, table, …)
# plus the Tailwind v4 design tokens, Stimulus sidecar loader, and
# Floating UI vendor bundle that they depend on.
#
# Host integration is one Bundler line + `rails g rbrun_ui:install`.
# See the engine class for the wiring details, and the install
# generator for what gets injected into the host app.
module RbrunUi
end
