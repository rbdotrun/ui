class RbrunUi::Ui::AreaFooter::Component < RbrunUi::ApplicationViewComponent
  option(:class_name, optional: true)

  renders_one :left
  renders_one :right

  def root_classes
    TailwindMerge::Merger.new.merge([
      "flex shrink-0 items-center justify-between gap-3 px-4 py-3",
      class_name
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <div class="<%= root_classes %>">
      <div class="min-w-0 flex-1">
        <% if left? %>
          <%= left %>
        <% else %>
          <%= content %>
        <% end %>
      </div>

      <% if right? %>
        <div class="shrink-0">
          <%= right %>
        </div>
      <% end %>
    </div>
  ERB
end
