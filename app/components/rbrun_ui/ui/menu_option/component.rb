# Shared interactive row shell for menu-like popups.
class RbrunUi::Ui::MenuOption::Component < RbrunUi::ApplicationViewComponent
  option(:tag,          default: proc { :button })
  option(:title)
  option(:subtitle,     optional: true)
  option(:icon,         optional: true)
  option(:avatar,       optional: true)
  option(:size,         default: proc { :sm })
  option(:selected,     default: proc { false })
  option(:selected_class_name, optional: true)
  option(:html_options, default: proc { {} })

  BASE_CLASSES = %w[
    block w-full cursor-pointer rounded px-2.5 py-1.5
    text-left ui-focus-ring
    hover:bg-stone-100/60 hover:text-stone-900
    focus:bg-stone-100/60 focus:text-stone-900 focus:outline-none
    [&[disabled]]:pointer-events-none [&[disabled]]:opacity-50
  ].freeze

  ICON_GLYPH_CLASSES = {
    sm: "h-4 w-4",
    md: "h-4 w-4",
    lg: "h-[18px] w-[18px]"
  }.freeze

  renders_one :leading

  def row_classes
    classes = BASE_CLASSES.dup
    classes << (selected_class_name || "bg-stone-100/60 text-stone-900") if selected
    classes.join(" ")
  end

  def merged_html_options
    options = html_options.deep_dup
    options[:class] = [row_classes, options[:class]].compact.join(" ")
    options
  end

  def icon_leading_class
    "flex h-5 w-5 shrink-0 items-center justify-center text-stone-500"
  end

  def icon_glyph_class
    ICON_GLYPH_CLASSES.fetch(size)
  end

  erb_template <<~ERB
    <%= content_tag tag, **merged_html_options do %>
      <% if leading? %>
        <%= render RbrunUi::Ui::Item::Component.new(
              title:,
              subtitle:,
              icon:,
              avatar:,
              size:
            ) do |item| %>
          <% item.with_leading do %>
            <%= leading %>
          <% end %>
        <% end %>
      <% elsif icon.present? %>
        <%= render RbrunUi::Ui::Item::Component.new(
              title:,
              subtitle:,
              size:
            ) do |item| %>
          <% item.with_leading do %>
            <span class="<%= icon_leading_class %>">
              <%= lucide_icon(icon, class: icon_glyph_class) %>
            </span>
          <% end %>
        <% end %>
      <% else %>
        <%= render RbrunUi::Ui::Item::Component.new(
              title:,
              subtitle:,
              avatar:,
              size:
            ) %>
      <% end %>
    <% end %>
  ERB
end
