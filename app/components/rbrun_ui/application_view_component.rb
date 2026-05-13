require "view_component"
require "view_component_contrib"
require "view_component_contrib/base"
require "view_component_contrib/style_variants"
require "dry/initializer"
require "tailwind_merge"
require "lucide-rails"

module RbrunUi
  # Base class for every UI component shipped by this gem.
  #
  # What every subclass inherits:
  #
  #   - `option(:foo, default: proc { ... })` syntax via Dry::Initializer.
  #
  #   - The `style do; base { %w[...] }; variants do; ...; end; end`
  #     DSL via ViewComponentContrib::StyleVariants.
  #
  #   - Automatic Tailwind class de-duplication via TailwindMerge —
  #     when a variant composition produces conflicting utilities
  #     (e.g. `px-2` from base + `px-4` from a size variant), the
  #     later one wins.
  #
  #   - `lucide_icon "name", class: "..."` via direct
  #     `LucideRails::RailsHelper` include — no `helpers.lucide_icon`
  #     indirection needed in component templates.
  #
  #   - `controller_name` — derives the engine's Stimulus identifier
  #     from the component's Ruby class name. See its docstring.
  #
  # Layout convention: `app/components/rbrun_ui/ui/<name>/component.rb`,
  # class name `RbrunUi::Ui::<Name>::Component`. The `ui("name", ...)`
  # helper (RbrunUi::ApplicationHelper) does the constantize lookup.
  #
  # Behavior sidecars: optional `controller.js` next to `component.rb`
  # for Stimulus-driven components — picked up by the engine loader
  # at `app/javascript/rbrun_ui/controllers/loader.js` and registered
  # under `controller_name` (e.g. `rbrun-ui--ui--popover`). Style
  # sidecars: NONE — all styling lives in the `style do` block here
  # as Tailwind utility classes.
  class ApplicationViewComponent < ViewComponentContrib::Base
    extend Dry::Initializer
    include ViewComponentContrib::StyleVariants
    include LucideRails::RailsHelper

    SEMANTIC_COLOR_SUITES = {
      stone: {
        border: "border-stone-200",
        bg_soft: "bg-stone-100",
        bg_panel: "bg-white",
        text: "text-stone-700",
        title: "text-stone-950",
        body_with_title: "text-stone-600",
        body_without_title: "text-stone-700",
        icon: "text-stone-500"
      },
      amber: {
        border: "border-amber-200",
        bg_soft: "bg-amber-50",
        bg_panel: "bg-amber-50/90",
        text: "text-amber-700",
        title: "text-amber-900",
        body_with_title: "text-amber-800",
        body_without_title: "text-amber-800",
        icon: "text-amber-600"
      },
      sky: {
        border: "border-sky-200",
        bg_soft: "bg-sky-50",
        bg_panel: "bg-sky-50/90",
        text: "text-sky-700",
        title: "text-sky-900",
        body_with_title: "text-sky-800",
        body_without_title: "text-sky-800",
        icon: "text-sky-600"
      },
      emerald: {
        border: "border-emerald-200",
        bg_soft: "bg-emerald-50",
        bg_panel: "bg-emerald-50/80",
        text: "text-emerald-700",
        title: "text-emerald-900",
        body_with_title: "text-emerald-800",
        body_without_title: "text-emerald-800",
        icon: "text-emerald-600"
      },
      rose: {
        border: "border-rose-200",
        bg_soft: "bg-rose-50",
        bg_panel: "bg-rose-50/90",
        text: "text-rose-700",
        title: "text-rose-900",
        body_with_title: "text-rose-800",
        body_without_title: "text-rose-800",
        icon: "text-rose-600"
      }
    }.freeze

    style_config.postprocess_with do |classes|
      TailwindMerge::Merger.new.merge(classes.join(" "))
    end

    # Stimulus identifier for THIS component's sidecar controller.
    #
    # Derived from the class name so the same string is used at:
    #   - `data-controller="<%= controller_name %>"` in the template
    #   - `data-action="…->controller_name#…"` in the template
    #   - `data-<%= controller_name %>-target="…"` in the template
    #   - `application.register("<%= controller_name %>", …)` by the
    #     engine's loader.js (which derives the same string from the
    #     importmap key)
    #
    # Mapping:
    #   RbrunUi::Ui::Button::Component   → "rbrun-ui--button"
    #   RbrunUi::Ui::Popover::Component  → "rbrun-ui--popover"
    #   RbrunUi::Ui::TableRow::Component → "rbrun-ui--table-row"
    #
    # The `Ui::` middle namespace is stripped so the identifier stays
    # short and human-typeable. The Ruby class name still carries
    # `Ui::` for namespace hygiene; the Stimulus identifier is a
    # separate, terser name designed to be typed in `data:` hashes.
    #
    # `_` → `-` is the Stimulus convention (underscores are illegal in
    # identifiers); `/` → `--` mirrors how the loader joins importmap
    # path segments.
    def controller_name
      self.class.controller_name
    end

    class << self
      def controller_name
        @controller_name ||= begin
          relative = name.sub(/^RbrunUi::/, "")
                         .sub(/^Ui::/, "")
                         .sub(/::Component$/, "")
          path     = relative.underscore         # "table_row"
          slug     = path.gsub("/", "--")        # "table_row"
                       .tr("_", "-")             # "table-row"
          "rbrun-ui--#{slug}"
        end
      end
    end

    # Stimulus data-attribute helpers. Each returns a hash suitable
    # for splatting into a Rails `data:` argument or merging into one
    # the caller already has. They use the component's own
    # `controller_name`, so renaming a component's class auto-updates
    # every reference.
    def stimulus_controller
      { controller: controller_name }
    end

    def stimulus_target(name)
      { "#{controller_name}-target" => name }
    end

    def stimulus_action(event, method = nil)
      method ||= event
      { action: "#{event}->#{controller_name}##{method}" }
    end

    def stimulus_value(name, value)
      { "#{controller_name}-#{name}-value" => value }
    end
  end
end
