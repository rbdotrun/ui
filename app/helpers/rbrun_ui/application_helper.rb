module RbrunUi
  module ApplicationHelper
    # Render a UI component by short name.
    #
    #   <%= ui("button", label: "Save") %>
    #   <%= ui("button", label: "Save", variant: :secondary) %>
    #   <%= ui("badge", label: "New") do %>...<% end %>
    #
    # Maps `"button"` → `RbrunUi::Ui::Button::Component`. Components
    # live at `app/components/rbrun_ui/ui/<name>/component.rb`. See
    # `app/components/rbrun_ui/application_view_component.rb` for the
    # base class and the `style do` DSL conventions.
    #
    # Auto-included into every controller via the `rbrun_ui.helpers`
    # initializer in `lib/rbrun_ui/engine.rb`, so host views can call
    # `ui(...)` even without mounting the engine.
    def ui(name, *args, **kwargs, &block)
      klass = "RbrunUi::Ui::#{name.to_s.tr('-', '_').camelize}::Component".constantize
      render(klass.new(*args, **kwargs), &block)
    end

    # ─── Dispatch shortcuts ────────────────────────────────────────
    # The most common case for cross-component dispatch is "click a
    # button to close the panel I'm rendered inside". Hand-typing
    # `data: { action: "click->rbrun-ui--dialog#close" }` everywhere
    # is mechanical drudgery; these helpers spell the action verb in
    # the helper name and return a hash you splat into `data:`.
    #
    # Usage:
    #   <%= ui("button", label: "Cancel", data: ui_dialog_close) %>
    #   <%= ui("button", icon: "x", variant: :ghost, data: ui_drawer_close) %>
    #
    # Each helper covers one (controller, method) pair the components
    # actually expose. If you need a different combination, build the
    # hash inline — `{ action: "click->rbrun-ui--<name>#<method>" }`.

    def ui_dialog_close
      { action: "click->rbrun-ui--dialog#close" }
    end

    def ui_drawer_close
      { action: "click->rbrun-ui--drawer#close" }
    end

    def ui_popover_close
      { action: "click->rbrun-ui--popover#close" }
    end

    def flash_component_variant(type)
      case type.to_sym
      when :notice, :success then :notice
      when :alert, :error    then :alert
      when :warning          then :warning
      else :info
      end
    end
  end
end
