class RbrunUi::Ui::TableCell::Component < RbrunUi::ApplicationViewComponent
  option(:header,      default: proc { false })
  option(:label,       optional: true)
  option(:sortable,    default: proc { false })
  option(:interactive, default: proc { true })
  option(:class_name,  optional: true)

  def root_classes
    TailwindMerge::Merger.new.merge([
      (header ? "px-3 py-2 text-left text-xs font-semibold uppercase tracking-[0.14em] text-stone-500" : "px-3 py-3 align-middle text-sm text-stone-700"),
      class_name
    ].compact.join(" "))
  end

  def tag_name
    header ? :th : :td
  end

  def sort_button_classes
    TailwindMerge::Merger.new.merge([
      "inline-flex items-center gap-1 rounded-sm text-stone-600 uppercase tracking-[0.14em] transition-colors",
      (interactive ? "hover:text-stone-900" : "pointer-events-none")
    ].join(" "))
  end

  erb_template <<~ERB
    <%= content_tag tag_name, class: root_classes do %>
      <% if content.present? %>
        <%= content %>
      <% elsif header && sortable %>
        <button type="button" class="<%= sort_button_classes %>" <%= "disabled" unless interactive %>>
          <%= label %>
          <%= lucide_icon("arrow-up-down", class: "h-3.5 w-3.5") %>
        </button>
      <% else %>
        <%= label %>
      <% end %>
    <% end %>
  ERB
end
