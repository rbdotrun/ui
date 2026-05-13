class RbrunUi::Ui::Alert::Component < RbrunUi::ApplicationViewComponent
  option(:title,       optional: true)
  option(:message,     optional: true)
  option(:variant,     default: proc { :info })
  option(:icon,        optional: true)
  option(:icon_class,  optional: true)
  option(:class_name,  optional: true)
  option(:body_class,  optional: true)

  ICONS = {
    info: "info",
    success: "circle-check-big",
    warning: "triangle-alert",
    danger: "circle-alert"
  }.freeze

  VARIANT_SUITES = {
    info: :stone,
    success: :emerald,
    warning: :amber,
    danger: :rose
  }.freeze

  PANEL_CLASSES = {
    info: [SEMANTIC_COLOR_SUITES.dig(:stone, :border)],
    success: [
      SEMANTIC_COLOR_SUITES.dig(:emerald, :border),
      SEMANTIC_COLOR_SUITES.dig(:emerald, :bg_panel)
    ],
    warning: [
      SEMANTIC_COLOR_SUITES.dig(:amber, :border),
      SEMANTIC_COLOR_SUITES.dig(:amber, :bg_panel)
    ],
    danger: [
      SEMANTIC_COLOR_SUITES.dig(:rose, :border),
      SEMANTIC_COLOR_SUITES.dig(:rose, :bg_panel)
    ]
  }.freeze

  style do
    base do
      %w[
        flex items-start gap-3 rounded border bg-white px-4 py-3 text-sm
        text-stone-900 shadow-sm
      ]
    end

    variants do
      variant do
        info    { PANEL_CLASSES[:info] }
        success { PANEL_CLASSES[:success] }
        warning { PANEL_CLASSES[:warning] }
        danger  { PANEL_CLASSES[:danger] }
      end
    end
  end

  def resolved_icon
    icon || ICONS.fetch(variant.to_sym, ICONS[:info])
  end

  def root_class
    TailwindMerge::Merger.new.merge([style(variant:), class_name].compact.join(" "))
  end

  def resolved_icon_class
    palette = suite.fetch(:icon)

    TailwindMerge::Merger.new.merge(["mt-0.5 h-4 w-4 shrink-0", palette, icon_class].compact.join(" "))
  end

  def resolved_body_class
    TailwindMerge::Merger.new.merge(["min-w-0 flex-1", body_class].compact.join(" "))
  end

  def title_class
    "#{suite.fetch(:title)} font-medium leading-5"
  end

  def message_class
    key = title.present? ? :with_title : :without_title
    palette = suite.fetch(:"body_#{key}")
    classes = [palette, "leading-5"]
    classes.unshift("mt-1") if title.present?
    classes.join(" ")
  end

  def suite
    SEMANTIC_COLOR_SUITES.fetch(VARIANT_SUITES.fetch(variant.to_sym, :stone))
  end

  erb_template <<~ERB
    <section class="<%= root_class %>">
      <%= lucide_icon(resolved_icon, class: resolved_icon_class) %>

      <div class="<%= resolved_body_class %>">
        <% if title.present? %>
          <p class="<%= title_class %>"><%= title %></p>
        <% end %>

        <% if message.present? %>
          <p class="<%= message_class %>"><%= message %></p>
        <% end %>

        <%= content if content.present? %>
      </div>
    </section>
  ERB
end
