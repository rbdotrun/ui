# RbrunUi::Ui::Menu::Component — keyboard-navigable list of actions.
#
# Items are added via four instance methods on the component, called
# in the rendering block. They're stored in insertion order and emitted
# in the template:
#
#   <%= ui("menu") do |m| %>
#     <% m.header    "Signed in as Ben" %>
#     <% m.link      "Profile",  href: profile_path, icon: "user" %>
#     <% m.link      "Settings", href: settings_path %>
#     <% m.separator %>
#     <% m.button    "Sign out", href: session_path, method: :delete %>
#   <% end %>
#
# Why plain methods (vs ViewComponent polymorphic slots)? The slot writers
# would be `with_item_link`, `with_item_button`, … — wordy. And separate
# `renders_many :links` / `:buttons` / etc. slots can't preserve insertion
# order across types. Plain methods on the component, accumulating into
# `@items`, give us clean callsites AND ordering.
#
# Item builders:
#   link(label, href:, icon: nil)
#       — renders an <a>. Icon is any lucide-rails name (kebab-case).
#   button(label, href:, method: :post, icon: nil, confirm: nil)
#       — renders a `button_to` form. Use for destructive / non-GET actions.
#   separator
#       — renders an <hr> divider.
#   header(text)
#       — renders a small group label.
#
# Keyboard nav: ArrowUp/ArrowDown move focus across link+button items,
# Home/End jump to first/last, Enter/Space activate. Roving tabindex
# (one item is tabIndex=0, the rest -1). Focus resets to the first item
# whenever the menu becomes visible — handy when the menu lives inside
# a popover that opens and closes. See `controller.js`.
#
# A menu can be used standalone (e.g. an inline action list) or composed
# inside a `RbrunUi::Ui::Popover` (the dropdown pattern).
# `RbrunUi::Ui::Select::Component` composes both internally for form selects.
class RbrunUi::Ui::Menu::Component < RbrunUi::ApplicationViewComponent
  option(:item_size,          default: proc { :sm })
  option(:searchable,         default: proc { false })
  option(:search_placeholder, default: proc { "Search…" })
  option(:footer_action,      optional: true)

  # ─── Item: link (<a>) ─────────────────────────────────────────────
  class Link < RbrunUi::ApplicationViewComponent
    option(:label)
    option(:href)
    option(:icon, optional: true)
    option(:size, default: proc { :md })

    # Identifier of the parent Menu controller — items declare
    # themselves as the menu's `item` target so the keyboard navigator
    # walks them.
    def menu_controller
      RbrunUi::Ui::Menu::Component.controller_name
    end

    def menu_option_html_options
      {
        href: href,
        role: "menuitem",
        tabindex: -1,
        data: {
          "#{menu_controller}-target"     => "item",
          "#{menu_controller}-filterable" => label.downcase
        }
      }
    end

    erb_template <<~ERB
      <%= render RbrunUi::Ui::MenuOption::Component.new(
            tag: :a,
            title: label,
            icon: icon,
            size:,
            html_options: menu_option_html_options
          ) %>
    ERB
  end

  # ─── Item: button (button_to form) ────────────────────────────────
  # Used for non-GET actions (DELETE sign-out, POST submit, …). Renders
  # as <form><button>…</button></form>; the keyboard-nav target is the
  # inner <button>.
  class Button < RbrunUi::ApplicationViewComponent
    option(:label)
    option(:href)
    option(:method,  default: proc { :post })
    option(:icon,    optional: true)
    option(:confirm, optional: true)
    option(:size,    default: proc { :md })

    def menu_controller
      RbrunUi::Ui::Menu::Component.controller_name
    end

    def button_attrs
      attrs = {
        method:,
        role: "menuitem",
        tabindex: -1,
        form: { class: "contents" },
        data: {
          "#{menu_controller}-target"     => "item",
          "#{menu_controller}-filterable" => label.downcase
        }
      }
      attrs[:data][:turbo_confirm] = confirm if confirm
      attrs
    end

    erb_template <<~ERB
      <%= button_to href, **button_attrs do %>
        <%= render RbrunUi::Ui::MenuOption::Component.new(title: label, icon: icon, size:) %>
      <% end %>
    ERB
  end

  # ─── Item: separator ──────────────────────────────────────────────
  class Separator < RbrunUi::ApplicationViewComponent
    def menu_controller
      RbrunUi::Ui::Menu::Component.controller_name
    end

    erb_template <<~ERB
      <hr role="separator"
          data-<%= menu_controller %>-target="static"
          class="my-1 border-t border-border" />
    ERB
  end

  # ─── Item: header (group label) ───────────────────────────────────
  class Header < RbrunUi::ApplicationViewComponent
    option(:text)

    def menu_controller
      RbrunUi::Ui::Menu::Component.controller_name
    end

    erb_template <<~ERB
      <div data-<%= menu_controller %>-target="static"
           class="px-2.5 pt-1 pb-0.5 text-xs font-medium uppercase tracking-wide text-stone-500">
        <%= text %>
      </div>
    ERB
  end

  renders_many :items, types: {
    link: Link,
    button: Button,
    separator: Separator,
    header: Header
  }

  def link(label, href:, icon: nil)
    with_item_link(label:, href:, icon:, size: item_size)
    nil
  end

  def button(label, href:, method: :post, icon: nil, confirm: nil)
    with_item_button(label:, href:, method:, icon:, confirm:, size: item_size)
    nil
  end

  def separator
    with_item_separator
    nil
  end

  def header(text)
    with_item_header(text:)
    nil
  end

  def footer_action?
    footer_action.present?
  end

  def footer_label
    footer_action.fetch(:label)
  end

  def footer_href
    footer_action.fetch(:href)
  end

  # Body attributes for the popup_list shell — the `body` target the
  # menu controller manipulates plus the `role="menu"` ARIA hint.
  def popup_body_attributes
    {
      data: { "#{controller_name}-target" => "body" },
      role: "menu"
    }
  end

  erb_template <<~ERB
    <%= render RbrunUi::Ui::PopupList::Component.new(
          searchable:,
          search_placeholder:,
          footer_action:,
          footer_size: item_size,
          body_attributes: popup_body_attributes
        ) do |list| %>
      <% group = list.with_group %>
      <% items.each do |item| %>
        <% group.with_item do %>
          <%= item %>
        <% end %>
      <% end %>
    <% end %>
  ERB
end
