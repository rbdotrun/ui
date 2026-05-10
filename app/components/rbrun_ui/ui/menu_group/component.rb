# Shared grouped section shell for menu-like popups.
#
# This component itself does NOT register a Stimulus controller. The
# `data-…-target="static"` attributes refer to the menu controller's
# `static` target — emitted by parent `RbrunUi::Ui::Menu` (via
# `RbrunUi::Ui::PopupList`), so the data attribute key uses the menu
# component's `controller_name`.
class RbrunUi::Ui::MenuGroup::Component < RbrunUi::ApplicationViewComponent
  option(:label,          optional: true)
  option(:show_separator, default: proc { false })

  # Menu controller's identifier — used to scope our `static` target
  # data attribute. Resolved lazily at render time so we don't force
  # `RbrunUi::Ui::Menu::Component` to autoload before this file is
  # done loading itself (Zeitwerk's autoload graph would deadlock if
  # `Menu` referenced `MenuGroup` back, which it does via PopupList).
  def menu_controller
    RbrunUi::Ui::Menu::Component.controller_name
  end

  HEADER_CLASSES = %w[
    px-2.5 py-1 text-xs font-medium uppercase tracking-wide text-stone-500
  ].freeze

  BODY_CLASSES = %w[
    flex flex-col gap-px
  ].freeze

  renders_many :items

  erb_template <<~ERB
    <% if label.present? %>
      <div class="<%= HEADER_CLASSES.join(' ') %>"
           data-<%= menu_controller %>-target="static"
           role="presentation">
        <%= label %>
      </div>
    <% end %>

    <div class="<%= BODY_CLASSES.join(' ') %>">
      <% items.each do |item| %>
        <%= item %>
      <% end %>
    </div>

    <% if show_separator %>
      <hr role="separator"
          data-<%= menu_controller %>-target="static"
          class="my-1 border-t border-border" />
    <% end %>
  ERB
end
