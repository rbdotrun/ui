# Shared interactive row shell for menu-like popups.
class RbrunUi::Ui::MenuOption::Component < RbrunUi::ApplicationViewComponent
  option(:tag,          default: proc { :button })
  option(:title)
  option(:subtitle,     optional: true)
  option(:icon,         optional: true)
  option(:avatar,       optional: true)
  option(:size,         default: proc { :sm })
  option(:selected,     default: proc { false })
  option(:html_options, default: proc { {} })

  BASE_CLASSES = %w[
    block w-full rounded px-2.5 py-2
    text-left ui-focus-ring
    hover:bg-stone-100/60 hover:text-stone-900
    focus:bg-stone-100/60 focus:text-stone-900 focus:outline-none
    [&[disabled]]:pointer-events-none [&[disabled]]:opacity-50
  ].freeze

  renders_one :leading

  def row_classes
    classes = BASE_CLASSES.dup
    classes << "bg-stone-100/60 text-stone-900" if selected
    classes.join(" ")
  end

  def merged_html_options
    options = html_options.deep_dup
    options[:class] = [row_classes, options[:class]].compact.join(" ")
    options
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
      <% else %>
        <%= render RbrunUi::Ui::Item::Component.new(
              title:,
              subtitle:,
              icon:,
              avatar:,
              size:
            ) %>
      <% end %>
    <% end %>
  ERB
end
