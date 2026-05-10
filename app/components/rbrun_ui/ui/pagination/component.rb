class RbrunUi::Ui::Pagination::Component < RbrunUi::ApplicationViewComponent
  option(:total_count,           default: proc { 0 })
  option(:rows_per_page,         default: proc { 10 })
  option(:rows_per_page_options, default: proc { [10, 20, 30, 40, 50] })
  option(:page,                  default: proc { 1 })
  option(:page_count,            default: proc { 1 })
  option(:interactive,           default: proc { true })

  def page_label
    "Page #{page} of #{page_count}"
  end

  def first_page?
    page <= 1
  end

  def last_page?
    page >= page_count
  end

  def rows_per_page_select_options
    rows_per_page_options.map { |value| [value.to_s, value.to_s] }
  end

  def pager_button_classes(disabled: false)
    TailwindMerge::Merger.new.merge([
      "inline-flex h-8 w-8 items-center justify-center rounded-md border border-border bg-white text-stone-700 transition-colors",
      (interactive ? "hover:bg-secondary" : "pointer-events-none"),
      (disabled ? "cursor-not-allowed opacity-40" : nil)
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <div class="flex flex-col gap-4 lg:flex-row lg:items-center">
      <div class="text-sm text-stone-500">Total of <%= total_count %> record(s).</div>

      <div class="flex flex-col gap-3 sm:ml-auto sm:flex-row sm:flex-wrap sm:items-center sm:justify-end sm:gap-4">
        <div class="flex items-center gap-3">
          <span class="text-sm font-medium text-stone-700">Rows per page</span>
          <%= render RbrunUi::Ui::Select::Component.new(
                name: "pagination[limit]",
                options: rows_per_page_select_options,
                value: rows_per_page.to_s,
                size: :sm,
                disabled: !interactive,
                trigger_class_name: "min-w-20"
              ) %>
        </div>

        <div class="text-sm font-medium text-stone-700"><%= page_label %></div>

        <nav class="flex items-center gap-2" aria-label="Pagination">
          <button type="button" class="<%= pager_button_classes(disabled: first_page?) %>" <%= "disabled" if first_page? || !interactive %>>
            <%= lucide_icon("chevrons-left", class: "h-4 w-4") %>
            <span class="sr-only">Go to first page</span>
          </button>
          <button type="button" class="<%= pager_button_classes(disabled: first_page?) %>" <%= "disabled" if first_page? || !interactive %>>
            <%= lucide_icon("chevron-left", class: "h-4 w-4") %>
            <span class="sr-only">Go to previous page</span>
          </button>
          <button type="button" class="<%= pager_button_classes(disabled: last_page?) %>" <%= "disabled" if last_page? || !interactive %>>
            <%= lucide_icon("chevron-right", class: "h-4 w-4") %>
            <span class="sr-only">Go to next page</span>
          </button>
          <button type="button" class="<%= pager_button_classes(disabled: last_page?) %>" <%= "disabled" if last_page? || !interactive %>>
            <%= lucide_icon("chevrons-right", class: "h-4 w-4") %>
            <span class="sr-only">Go to last page</span>
          </button>
        </nav>
      </div>
    </div>
  ERB
end
