require "rails/engine"
require "importmap-rails"
require "view_component"
require "view_component_contrib"
require "view_component_contrib/base"
require "view_component_contrib/style_variants"
require "dry/initializer"
require "tailwind_merge"
require "lucide-rails"

module RbrunUi
  # `RbrunUi.importmap` is declared here (not only in `lib/rbrun_ui.rb`)
  # because the engine's `rbrun_ui.importmap` initializer assigns to
  # it during boot, and the engine class is required BEFORE
  # `lib/rbrun_ui.rb` finishes loading. Declaring twice is harmless.
  class << self
    attr_accessor :importmap
  end

  # The engine wires four pieces:
  #
  #   1. Propshaft asset paths — `app/components` and `app/javascript`
  #      need to be in `assets.paths` so the engine's importmap can
  #      resolve sidecar `controller.js` files and the engine's
  #      JS modules at runtime.
  #
  #   2. Engine-owned `Importmap::Map` — `RbrunUi.importmap` is a
  #      separate instance from the host's `Rails.application.importmap`.
  #      The engine layout renders `javascript_importmap_tags(...,
  #      importmap: RbrunUi.importmap)`, giving engine pages a fully
  #      isolated JS module graph. Host JS and engine JS never collide.
  #
  #   3. Helper auto-include — `RbrunUi::ApplicationHelper` defines the
  #      `ui("name", ...)` shortcut for rendering components. Wired to
  #      `ActionController::Base` so it's available wherever the host
  #      mounts engine routes (and on engine routes too).
  #
  #   4. ViewComponent sidecar previews — if the host adds Lookbook
  #      later, our previews land at `app/components/rbrun_ui/ui/<name>/preview.rb`
  #      automatically.
  #
  # No `app.config.importmap.paths << ...` — that would merge the
  # engine's pins into the host's importmap, which is exactly the
  # leak we want to avoid. The engine's importmap is parallel, not
  # overlaid.
  class Engine < ::Rails::Engine
    isolate_namespace RbrunUi

    initializer "rbrun_ui.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("app/components")
        app.config.assets.paths << root.join("app/assets/stylesheets")
      end
    end

    initializer "rbrun_ui.helpers" do
      # Hook MUST be `:action_controller_base`, not `:action_controller`.
      # The bare `:action_controller` symbol fires for BOTH
      # `ActionController::Base` and `ActionController::API`, but
      # `helper` is only defined on Base. With the bare symbol, any
      # host-app or sibling-engine controller that inherits from
      # `ActionController::API` blows up at load time with
      # `NoMethodError: undefined method 'helper' for class ActionController::API`.
      # The cache_sweeper hook a few lines below already uses
      # `:action_controller_base` correctly — same pattern here.
      ActiveSupport.on_load(:action_controller_base) do
        helper RbrunUi::ApplicationHelper
      end
    end

    initializer "rbrun_ui.importmap", before: "importmap" do |app|
      RbrunUi.importmap = Importmap::Map.new
      # Draw host's importmap first so engine code can reference host
      # pins if needed (rare, but cheap to support). Then draw the
      # engine's own — engine pins take precedence on conflict.
      RbrunUi.importmap.draw(app.root.join("config/importmap.rb")) if app.root.join("config/importmap.rb").exist?
      RbrunUi.importmap.draw(root.join("config/importmap.rb"))
      RbrunUi.importmap.cache_sweeper(watches: root.join("app/javascript"))
      RbrunUi.importmap.cache_sweeper(watches: root.join("app/components"))

      # Also merge the engine's pins into the HOST's importmap so engine
      # components used on host pages (`ui("dialog")`, `ui("popover")`)
      # have their Stimulus sidecars resolvable from the host's Stimulus
      # app. Without this, `Rails.application.importmap` has zero
      # rbrun_ui entries → sidecars never load → markup renders but
      # `data-controller="rbrun-ui--dialog"` has no module to bind to →
      # clicks are inert. Same trick aeno uses (see lib/aeno/engine.rb).
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action { RbrunUi.importmap.cache_sweeper.execute_if_updated }
      end
    end

    initializer "rbrun_ui.view_component" do
      ActiveSupport.on_load(:view_component) do
        begin
          require "view_component_contrib/preview/sidecarable"
          require "view_component_contrib/preview/abstract"
          ViewComponent::Preview.extend ViewComponentContrib::Preview::Sidecarable
          ViewComponent::Preview.extend ViewComponentContrib::Preview::Abstract
        rescue LoadError
          # Older view_component-contrib without preview modules — the
          # gem still works, only Lookbook preview discovery is lost.
        end
      end
    end
  end
end
