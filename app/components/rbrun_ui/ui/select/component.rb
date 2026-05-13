# RbrunUi::Ui::Select::Component — form-facing select / multiselect.
#
# A custom dropdown that integrates with Rails forms via hidden inputs.
# It supports:
#   - single or multiple selection
#   - grouped options
#   - local-only search
#   - an optional footer action outside the listbox
#
# The popup layout mirrors RbrunUi::Ui::Menu:
#   - optional fixed search header
#   - scrollable list body
#   - optional fixed footer action
#
# Stimulus composition: Select hosts its OWN controller (state, hidden
# input syncing, trigger label) AND the Popover controller (open/close,
# Floating UI positioning) on the same root element. The popup body
# lives in a Menu (keyboard nav). Three controllers, three concerns,
# composed declaratively via `data-controller="<a> <b>"`.
class RbrunUi::Ui::Select::Component < RbrunUi::ApplicationViewComponent
  option(:item_size,          default: proc { :sm })
  option(:name)
  option(:options,            default: proc { [] }) # rubocop:disable Style/OptionHash
  option(:groups,             optional: true)
  option(:value,              optional: true)
  option(:placeholder,        default: proc { "Select…" })
  option(:size,               default: proc { :md })
  option(:id,                 optional: true)
  option(:searchable,         default: proc { false })
  option(:search_placeholder, default: proc { "Search…" })
  option(:footer_action,      optional: true)
  option(:multiple,           default: proc { false })
  option(:with_checkbox,      default: proc { false })
  option(:disabled,           default: proc { false })
  option(:trigger_class_name, optional: true)

  TRIGGER_SIZE_CLASSES = {
    sm: %w[h-7 px-2.5 text-xs],
    md: %w[h-8 px-3 text-sm],
    lg: %w[h-10 px-4 text-base]
  }.freeze

  SELECT_MARKER_CLASSES = %w[
    flex h-4 w-4 shrink-0 items-center justify-center text-stone-900/80
  ].freeze

  # Cross-component identifiers — resolved lazily.
  def popover_controller
    RbrunUi::Ui::Popover::Component.controller_name
  end

  def menu_controller
    RbrunUi::Ui::Menu::Component.controller_name
  end

  def trigger_classes
    base = %w[
      inline-flex items-center justify-between gap-2 min-w-44
      rounded-md border border-border bg-white text-stone-900
      hover:bg-secondary
      ui-focus-ring
      disabled:cursor-not-allowed disabled:text-stone-400 disabled:hover:bg-white
    ]
    TailwindMerge::Merger.new.merge((base + TRIGGER_SIZE_CLASSES.fetch(size) + Array(trigger_class_name)).join(" "))
  end

  def normalized_groups
    source_groups = groups.presence || [{ label: nil, options: }]

    source_groups.map do |group|
      if group.is_a?(Hash)
        {
          label: group[:label] || group["label"],
          options: normalize_option_pairs(group[:options] || group["options"] || [])
        }
      else
        { label: nil, options: normalize_option_pairs(group) }
      end
    end.reject { |group| group[:options].empty? }
  end

  def selected_values
    @selected_values ||= Array(value).compact.map(&:to_s)
  end

  def selected?(option_value)
    selected_values.include?(option_value.to_s)
  end

  def selected_option_labels
    normalized_groups.flat_map { |group| group[:options] }
                     .filter_map { |label, option_value| label if selected?(option_value) }
  end

  def trigger_label
    labels = selected_option_labels

    return placeholder if labels.empty?
    return labels.first unless multiple
    return labels.join(", ") if labels.length <= 2

    "#{labels.length} selected"
  end

  def placeholder?
    selected_option_labels.empty?
  end

  def hidden_input_id
    id || name.gsub(/[^a-z0-9]+/i, "_").gsub(/^_+|_+$/, "")
  end

  def input_name
    return name unless multiple
    return name if name.end_with?("[]")

    "#{name}[]"
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

  def popover_id
    @popover_id ||= "select-#{SecureRandom.alphanumeric(8)}"
  end

  # Root data-controller string — Select + Popover composed on the
  # same element. The order is intentional: Select's `choose` action
  # calls into Popover (via dispatching `<popover>:close`), so both
  # controllers must be registered against the root.
  def root_controllers
    "#{controller_name} #{popover_controller}"
  end

  def root_data
    {
      controller: root_controllers,
      action: "#{popover_controller}:close->#{popover_controller}#close",
      "#{popover_controller}-placement-value" => "bottom-start",
      "#{popover_controller}-offset-value" => "4",
      "#{controller_name}-input-name-value" => input_name,
      "#{controller_name}-multiple-value" => multiple,
      "#{controller_name}-placeholder-value" => placeholder
    }
  end

  def trigger_data
    {
      "#{popover_controller}-target" => "trigger",
      "#{controller_name}-target" => "trigger",
      action: "click->#{popover_controller}#toggle"
    }
  end

  def hidden_input_data
    { "#{controller_name}-target" => "input" }
  end

  def listbox_body_attributes
    {
      data: { "#{menu_controller}-target" => "body" },
      role: "listbox",
      aria: { multiselectable: (multiple ? "true" : "false") }
    }
  end

  def option_html_options(label:, option_value:, selected:)
    {
      type: "button",
      role: "option",
      tabindex: -1,
      aria: { selected: selected },
      data: {
        "#{menu_controller}-target"     => "item",
        "#{controller_name}-target"     => "option",
        "#{menu_controller}-filterable" => label.downcase,
        value: option_value,
        label: label,
        action: "click->#{controller_name}#choose"
      }
    }
  end

  def selected_option_class
    with_checkbox ? "bg-stone-100/60 text-stone-900" : "bg-stone-200/70 text-stone-950"
  end

  # Indicator icon's data attribute. Built in Ruby so the
  # `controller_name` interpolation happens at render time, not at
  # heredoc-creation time when the class body loads.
  def indicator_data
    { "#{controller_name}-indicator" => true }
  end

  erb_template <<~ERB
    <div <%= tag.attributes(data: root_data) %>>
      <div data-<%= controller_name %>-target="inputs">
        <% if multiple %>
          <% selected_values.each do |selected_value| %>
            <input type="hidden"
                   name="<%= input_name %>"
                   value="<%= selected_value %>" />
          <% end %>
        <% else %>
          <%= hidden_field_tag name, selected_values.first, id: hidden_input_id, data: hidden_input_data %>
        <% end %>
      </div>

      <button type="button"
              class="<%= trigger_classes %>"
              <%= tag.attributes(data: trigger_data) %>
              <%= "disabled" if disabled %>
              aria-haspopup="listbox"
              aria-controls="<%= popover_id %>">
        <span class="<%= "text-stone-500" if placeholder? %>"
              data-<%= controller_name %>-target="label"><%= trigger_label %></span>
        <%= lucide_icon("chevron-down", class: "h-4 w-4 text-stone-500") %>
      </button>

      <div data-<%= popover_controller %>-target="content"
           id="<%= popover_id %>"
           hidden
           aria-hidden="true"
           class="top-0 left-0 m-0 w-max fixed z-50 min-w-56 bg-white text-stone-900 border border-border rounded-md shadow-lg focus:outline-none">
        <%= render RbrunUi::Ui::PopupList::Component.new(
              searchable:,
              search_placeholder:,
              footer_action:,
              footer_size: item_size,
              body_attributes: listbox_body_attributes
            ) do |list| %>
          <% normalized_groups.each_with_index do |group, group_index| %>
            <% menu_group = list.with_group(label: group[:label], show_separator: group_index < normalized_groups.length - 1) %>
            <% group[:options].each do |label, option_value| %>
              <% option_selected = selected?(option_value) %>
              <% menu_group.with_item do %>
                <% if with_checkbox %>
                  <%= render RbrunUi::Ui::MenuOption::Component.new(
                        title: label,
                        size: item_size,
                        selected: option_selected,
                        selected_class_name: selected_option_class,
                        html_options: option_html_options(label: label, option_value: option_value, selected: option_selected)
                      ) do |option| %>
                    <% option.with_leading do %>
                      <span class="<%= SELECT_MARKER_CLASSES.join(' ') %>" aria-hidden="true">
                        <%= lucide_icon("check",
                                        class: ["h-3.5 w-3.5 transition-opacity", (option_selected ? "opacity-100" : "opacity-0")].join(" "),
                                        data: indicator_data) %>
                      </span>
                    <% end %>
                  <% end %>
                <% else %>
                  <%= render RbrunUi::Ui::MenuOption::Component.new(
                        title: label,
                        size: item_size,
                        selected: option_selected,
                        selected_class_name: selected_option_class,
                        html_options: option_html_options(label: label, option_value: option_value, selected: option_selected)
                      ) %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
  ERB

  private

    def normalize_option_pairs(option_source)
      return option_source.map { |label, option_value| [label, option_value] } if option_source.is_a?(Hash)

      option_source.to_a.map do |entry|
        if entry.is_a?(Array)
          [entry[0], entry[1]]
        elsif entry.is_a?(Hash)
          [entry[:label] || entry["label"], entry[:value] || entry["value"]]
        else
          [entry, entry]
        end
      end
    end
end
