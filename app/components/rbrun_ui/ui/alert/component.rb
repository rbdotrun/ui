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

  style do
    base do
      %w[
        flex items-start gap-3 rounded-xl border bg-white px-4 py-3 text-sm
        text-stone-900 shadow-sm
      ]
    end

    variants do
      variant do
        info    { %w[border-border] }
        success { %w[border-emerald-200 bg-emerald-50/80] }
        warning { %w[border-amber-200 bg-amber-50/90] }
        danger  { %w[border-rose-200 bg-rose-50/90] }
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
    palette = case variant.to_sym
              when :success then "text-emerald-600"
              when :warning then "text-amber-600"
              when :danger  then "text-rose-600"
              else "text-stone-500"
              end

    TailwindMerge::Merger.new.merge(["mt-0.5 h-4 w-4 shrink-0", palette, icon_class].compact.join(" "))
  end

  def resolved_body_class
    TailwindMerge::Merger.new.merge(["min-w-0 flex-1", body_class].compact.join(" "))
  end

  erb_template <<~ERB
    <section class="<%= root_class %>">
      <%= lucide_icon(resolved_icon, class: resolved_icon_class) %>

      <div class="<%= resolved_body_class %>">
        <% if title.present? %>
          <p class="font-medium leading-5 text-stone-950"><%= title %></p>
        <% end %>

        <% if message.present? %>
          <p class="<%= title.present? ? 'mt-1 text-stone-600' : 'text-stone-700' %> leading-5"><%= message %></p>
        <% end %>

        <%= content if content.present? %>
      </div>
    </section>
  ERB
end
