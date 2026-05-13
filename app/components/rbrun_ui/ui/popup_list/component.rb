# Shared popup list shell with optional search and footer action.
#
# This component owns the `menu`-flavored Stimulus controller (the
# keyboard-navigable list). Cross-component refs:
#
#   - Popover → the search input's `initialFocus` target is owned by
#     whichever popover wraps us. Cleanly decoupled — popup_list
#     doesn't know it's inside a popover, just that the search input
#     would like to be focused first.
#
# Stimulus identifiers are looked up via `*_controller` instance
# methods so the heredoc-based ERB template can call `<%= … %>`
# without forcing identifier resolution at class-body load time.
class RbrunUi::Ui::PopupList::Component < RbrunUi::ApplicationViewComponent
  option(:searchable,         default: proc { false })
  option(:search_placeholder, default: proc { "Search…" })
  option(:footer_action,      optional: true)
  option(:footer_size,        default: proc { :sm })
  option(:body_attributes,    default: proc { {} })

  ROOT_CLASSES = %w[
    min-w-56 text-sm text-stone-900 focus:outline-none
  ].freeze

  BODY_CLASSES = %w[
    flex max-h-64 flex-col overflow-y-auto p-1
  ].freeze

  renders_many :groups, RbrunUi::Ui::MenuGroup::Component

  def footer_action?
    footer_action.present?
  end

  def footer_label
    footer_action.fetch(:label)
  end

  def footer_href
    footer_action.fetch(:href)
  end

  # Cross-component identifier for the menu controller (we host one
  # for keyboard navigation). Lazy-resolved to avoid forcing the
  # `Menu` constant to autoload before this class is fully loaded.
  def menu_controller
    RbrunUi::Ui::Menu::Component.controller_name
  end

  # Cross-component identifier for the popover controller — we don't
  # render a popover ourselves, but our search input asks the
  # surrounding popover (when there is one) to focus it on open.
  def popover_controller
    RbrunUi::Ui::Popover::Component.controller_name
  end

  # Search-input data hash. Built in Ruby (not interpolated into the
  # ERB heredoc) so identifier strings resolve at render time, not
  # class-body load time — heredocs eagerly evaluate `#{...}` and
  # would NameError on the instance methods.
  def search_input_data
    {
      "#{popover_controller}-target" => "initialFocus",
      "#{menu_controller}-target"    => "search",
      action: "input->#{menu_controller}#filter"
    }
  end

  def merged_body_attributes
    attrs = body_attributes.deep_dup
    attrs[:class] = [BODY_CLASSES.join(" "), attrs[:class]].compact.join(" ")
    attrs
  end

  erb_template <<~ERB
    <div class="<%= ROOT_CLASSES.join(' ') %>"
         data-controller="<%= menu_controller %>"
         data-action="keydown-><%= menu_controller %>#navigate">
      <% if searchable %>
        <div class="border-b border-border p-2">
          <%= render RbrunUi::Ui::Input::Component.new(
                type: "search",
                value: "",
                placeholder: search_placeholder,
                autocomplete: "off",
                data: search_input_data
              ) %>
        </div>
      <% end %>

      <div <%= tag.attributes(**merged_body_attributes) %>>
        <% groups.each do |group| %>
          <%= group %>
        <% end %>
      </div>

      <% if footer_action? %>
        <div class="border-t border-border p-1.5">
          <%= render RbrunUi::Ui::MenuOption::Component.new(
                tag: :a,
                title: footer_label,
                size: footer_size,
                html_options: { href: footer_href }
              ) %>
        </div>
      <% end %>
    </div>
  ERB
end
