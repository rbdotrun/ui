class RbrunUi::Ui::Dialog::Component < RbrunUi::ApplicationViewComponent
  option(:trigger_label,   default: proc { "Open dialog" })
  option(:trigger_variant, default: proc { :secondary })
  option(:trigger_size,    default: proc { :md })
  option(:panel_class,     default: proc { "h-[min(85vh,40rem)] w-full max-w-2xl" })
  option(:body_class,      optional: true)

  renders_one :trigger
  renders_one :header, RbrunUi::Ui::AreaHeader::Component
  renders_one :footer, RbrunUi::Ui::AreaFooter::Component

  def panel_classes
    TailwindMerge::Merger.new.merge(["outline-none", panel_class].join(" "))
  end

  erb_template <<~ERB
    <div data-controller="<%= controller_name %>"
         data-action="<%= controller_name %>:close-><%= controller_name %>#close">
      <div data-<%= controller_name %>-target="trigger"
           data-action="click-><%= controller_name %>#toggle"
           class="inline-flex">
        <% if trigger? %>
          <%= trigger %>
        <% else %>
          <%= render RbrunUi::Ui::Button::Component.new(
                label: trigger_label,
                variant: trigger_variant,
                size: trigger_size
              ) %>
        <% end %>
      </div>

      <div data-<%= controller_name %>-target="backdrop"
           data-action="mousedown-><%= controller_name %>#backdropPointerDown"
           hidden
           aria-hidden="true"
           class="fixed inset-0 z-50 flex items-center justify-center bg-stone-950/50 p-4 opacity-0 transition-opacity duration-200 data-[state=open]:opacity-100">
        <div data-<%= controller_name %>-target="panel"
             tabindex="-1"
             role="dialog"
             aria-modal="true"
             class="<%= TailwindMerge::Merger.new.merge([panel_classes, 'transition-all duration-200 opacity-0 scale-95 data-[state=open]:opacity-100 data-[state=open]:scale-100'].join(' ')) %>">
          <%= render RbrunUi::Ui::Card::Component.new(class_name: "h-full", body_class:) do |card| %>
            <% if header? %>
              <% card.with_header do %>
                <%= header %>
              <% end %>
            <% end %>

            <% if footer? %>
              <% card.with_footer do %>
                <%= footer %>
              <% end %>
            <% end %>

            <%= content %>
          <% end %>
        </div>
      </div>
    </div>
  ERB
end
