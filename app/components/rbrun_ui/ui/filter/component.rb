class RbrunUi::Ui::Filter::Component < RbrunUi::ApplicationViewComponent
  option(:search_placeholder, default: proc { "Filter..." })
  option(:search_value,       optional: true)
  option(:search_name,        default: proc { "q" })
  option(:search_id,          default: proc { "filter_query" })
  option(:selects,            default: proc { [] })
  option(:action_label,       optional: true)
  option(:interactive,        default: proc { true })

  def wrapper_classes
    "flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between"
  end

  def controls_classes
    "flex flex-1 flex-col gap-3 sm:flex-row sm:flex-wrap sm:items-center"
  end

  def search_input_classes
    "w-full max-w-[15.625rem]"
  end

  def normalized_selects
    selects.map do |select|
      {
        name: select[:name] || select["name"] || "filter[value]",
        placeholder: select[:placeholder] || select["placeholder"],
        value: select[:value] || select["value"],
        size: select[:size] || select["size"] || :md,
        trigger_class_name: select[:trigger_class_name] || select["trigger_class_name"],
        options: normalize_options(select[:options] || select["options"] || [])
      }
    end
  end

  erb_template <<~ERB
    <div class="<%= wrapper_classes %>">
      <div class="<%= controls_classes %>">
        <%= render RbrunUi::Ui::Input::Component.new(
              type: "search",
              name: search_name,
              id: search_id,
              placeholder: search_placeholder,
              value: search_value,
              disabled: !interactive,
              class_name: search_input_classes
            ) %>

        <% normalized_selects.each do |select| %>
          <%= render RbrunUi::Ui::Select::Component.new(
                name: select[:name],
                options: select[:options],
                placeholder: select[:placeholder],
                value: select[:value],
                size: select[:size],
                disabled: !interactive,
                trigger_class_name: select[:trigger_class_name]
              ) %>
        <% end %>
      </div>

      <% if action_label.present? %>
        <%= render RbrunUi::Ui::Button::Component.new(
              label: action_label,
              size: :md,
              disabled: !interactive
            ) %>
      <% end %>
    </div>
  ERB

  private

    def normalize_options(options)
      options.map do |option|
        if option.is_a?(Array)
          [option[0], option[1]]
        elsif option.is_a?(Hash)
          [option[:label] || option["label"], option[:value] || option["value"]]
        else
          [option.to_s.tr("-", "_").humanize, option]
        end
      end
    end
end
