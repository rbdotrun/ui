class RbrunUi::Ui::Table::Component < RbrunUi::ApplicationViewComponent
  option(:class_name, optional: true)

  renders_one :filters_section
  renders_one :header_section, RbrunUi::Ui::TableHeader::Component
  renders_many :rows, RbrunUi::Ui::TableRow::Component
  renders_one :footer_section
  renders_one :batch_section

  def filters(&block)
    with_filters_section(&block)
    nil
  end

  def header(**kwargs, &block)
    with_header_section(**kwargs, &block)
    nil
  end

  def row(**kwargs, &block)
    with_row(**kwargs, &block)
    nil
  end

  def paginate(collection = nil, **kwargs)
    total_count = kwargs.delete(:total_count) || collection&.size || 0
    rows_per_page = kwargs.delete(:rows_per_page) || total_count
    page = kwargs.delete(:page) || 1
    page_count = kwargs.delete(:page_count) || 1

    with_footer_section do
      render RbrunUi::Ui::Pagination::Component.new(
        total_count:,
        rows_per_page:,
        page:,
        page_count:,
        **kwargs
      )
    end

    nil
  end

  def footer(&block)
    with_footer_section(&block)
    nil
  end

  def batch(&block)
    with_batch_section(&block)
    nil
  end

  def select_all_checkbox(name: "select_all", checked: false, disabled: false, class_name: nil, **attrs)
    checkbox_tag(
      name:,
      checked:,
      disabled:,
      class_name:,
      data: {
        action: "change->#{controller_name}#toggleAll",
        "#{controller_name}-target" => "toggleAll"
      },
      **attrs
    )
  end

  def row_checkbox(name: "selected_ids[]", value: nil, checked: false, disabled: false, class_name: nil, **attrs)
    checkbox_tag(
      name:,
      value:,
      checked:,
      disabled:,
      class_name:,
      data: {
        action: "change->#{controller_name}#selectionChanged",
        "#{controller_name}-target" => "checkbox"
      },
      **attrs
    )
  end

  def root_classes
    TailwindMerge::Merger.new.merge([
      "space-y-4",
      class_name
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <div class="<%= root_classes %>" data-controller="<%= controller_name %>">
      <% if filters_section? %><%= filters_section %><% end %>

      <div class="overflow-x-auto rounded-xl border border-border bg-white" data-<%= controller_name %>-target="frame">
        <table class="min-w-full border-collapse text-sm">
          <% if header_section? %><%= header_section %><% end %>
          <tbody>
            <% rows.each do |row| %>
              <%= row %>
            <% end %>
          </tbody>
        </table>
      </div>

      <% if footer_section? %><%= footer_section %><% end %>

      <% if batch_section? %>
        <div class="pointer-events-none fixed bottom-6 left-0 z-40 hidden" data-<%= controller_name %>-target="batchDock" aria-hidden="true">
          <div class="pointer-events-auto flex items-center justify-between gap-4 rounded-xl border border-border bg-white px-4 py-3 shadow-lg" data-<%= controller_name %>-target="batchBar">
            <div class="text-sm font-medium text-stone-900">
              <span data-<%= controller_name %>-target="selectedCount">0</span> selected
            </div>
            <div class="flex items-center gap-2">
              <%= batch_section %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
  ERB

  private

    def checkbox_tag(name:, checked:, disabled:, class_name:, data:, **attrs)
      classes = TailwindMerge::Merger.new.merge([
        "h-4 w-4 rounded border border-border text-stone-900 accent-stone-900",
        class_name
      ].compact.join(" "))

      helpers.tag.input(**{
        type: "checkbox",
        name:,
        value: attrs.delete(:value),
        checked:,
        disabled:,
        class: classes,
        data:
      }.merge(attrs).compact)
    end
end
