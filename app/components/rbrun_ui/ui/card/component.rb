class RbrunUi::Ui::Card::Component < RbrunUi::ApplicationViewComponent
  option(:class_name, optional: true)
  option(:body_class, optional: true)

  renders_one :header
  renders_one :footer

  def root_classes
    TailwindMerge::Merger.new.merge([
      "flex h-full min-h-0 flex-col overflow-hidden rounded-xl border border-border bg-white shadow-sm",
      class_name
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <div class="<%= root_classes %>">
      <%= render RbrunUi::Ui::Area::Component.new(body_class:) do |area| %>
        <% if header? %>
          <% area.with_header do %>
            <div class="border-b border-border">
              <%= header %>
            </div>
          <% end %>
        <% end %>

        <% if footer? %>
          <% area.with_footer do %>
            <div class="border-t border-border">
              <%= footer %>
            </div>
          <% end %>
        <% end %>

        <%= content %>
      <% end %>
    </div>
  ERB
end
