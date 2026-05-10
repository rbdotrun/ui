class RbrunUi::Ui::TableRow::Component < RbrunUi::ApplicationViewComponent
  option(:hoverable,  default: proc { true })
  option(:class_name, optional: true)

  renders_many :cells, RbrunUi::Ui::TableCell::Component

  def cell(**kwargs, &block)
    with_cell(**kwargs, &block)
    nil
  end

  def root_classes
    TailwindMerge::Merger.new.merge([
      "border-t border-border first:border-t-0",
      (hoverable ? "hover:bg-stone-50/80" : nil),
      class_name
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <tr class="<%= root_classes %>">
      <% cells.each do |cell| %>
        <%= cell %>
      <% end %>
    </tr>
  ERB
end
