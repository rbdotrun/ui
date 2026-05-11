class RbrunUi::Ui::Flash::Component < RbrunUi::ApplicationViewComponent
  DEFAULT_DURATION = 4_200

  option(:title,        optional: true)
  option(:message)
  option(:variant,      default: proc { :info })
  option(:duration,     default: proc { DEFAULT_DURATION })
  option(:dismissible,  default: proc { true })
  option(:class_name,   optional: true)

  VARIANT_MAP = {
    notice: :success,
    success: :success,
    alert: :danger,
    error: :danger,
    warning: :warning,
    info: :info
  }.freeze

  TITLES = {
    success: "Success",
    danger: "Action needed",
    warning: "Heads up",
    info: "Notice"
  }.freeze

  style do
    base do
      %w[
        pointer-events-auto w-full max-w-sm transition duration-300 ease-out
        translate-y-6 opacity-0 data-[state=open]:translate-y-0
        data-[state=open]:opacity-100 data-[state=closing]:translate-y-2
        data-[state=closing]:opacity-0 motion-reduce:transform-none
        motion-reduce:transition-none
      ]
    end
  end

  def resolved_variant
    VARIANT_MAP.fetch(variant.to_sym, :info)
  end

  def resolved_title
    title.presence || TITLES.fetch(resolved_variant)
  end

  def root_class
    TailwindMerge::Merger.new.merge([style, class_name].compact.join(" "))
  end

  def resolved_duration
    duration || DEFAULT_DURATION
  end

  def data_attributes
    stimulus_controller
      .merge(stimulus_value(:duration, resolved_duration))
      .merge(action: [
        "mouseenter->#{controller_name}#pause",
        "mouseleave->#{controller_name}#resume",
        "turbo:before-cache@document->#{controller_name}#removeImmediately"
      ].join(" "))
  end

  erb_template <<~ERB
    <article class="<%= root_class %>"
             data-state="closed"
             role="<%= resolved_variant == :danger ? 'alert' : 'status' %>"
             aria-live="<%= resolved_variant == :danger ? 'assertive' : 'polite' %>"
             data-controller="<%= data_attributes[:controller] %>"
             data-<%= controller_name %>-duration-value="<%= resolved_duration %>"
             data-action="<%= data_attributes[:action] %>">
      <div class="relative">
        <%= render RbrunUi::Ui::Alert::Component.new(
              title: resolved_title,
              message: message,
              variant: resolved_variant,
              class_name: "pr-10 rounded-2xl bg-white/95 shadow-lg shadow-stone-950/12 ring-1 ring-black/5 backdrop-blur-sm"
            ) %>

        <% if dismissible %>
          <button type="button"
                  aria-label="Dismiss notification"
                  class="absolute right-3 top-3 inline-flex h-6 w-6 items-center justify-center rounded-full text-stone-400 transition hover:bg-stone-100 hover:text-stone-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-stone-900"
                  data-action="click-><%= controller_name %>#close">
            <%= lucide_icon("x", class: "h-3.5 w-3.5") %>
          </button>
        <% end %>
      </div>
    </article>
  ERB
end
