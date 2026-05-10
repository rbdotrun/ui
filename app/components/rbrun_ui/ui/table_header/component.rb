class RbrunUi::Ui::TableHeader::Component < RbrunUi::ApplicationViewComponent
  option(:class_name, optional: true)

  renders_many :cells, RbrunUi::Ui::TableCell::Component

  def cell(**kwargs, &block)
    with_cell(header: true, **kwargs, &block)
    nil
  end

  def root_classes
    TailwindMerge::Merger.new.merge([
      "border-b border-border bg-stone-50/80",
      class_name
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <thead class="<%= root_classes %>">
      <tr>
        <% cells.each do |cell| %>
          <%= cell %>
        <% end %>
      </tr>
    </thead>
  ERB
end
