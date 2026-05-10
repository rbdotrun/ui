require "test_helper"

class RbrunUi::Ui::Filter::ComponentTest < ViewComponent::TestCase
  test "renders a reusable disabled filter strip with selects and action" do
    render_inline(
      RbrunUi::Ui::Filter::Component.new(
        search_placeholder: "Filter tasks...",
        search_value: "docs",
        action_label: "Search",
        interactive: false,
        selects: [
          { name: "filters[status]", placeholder: "Status", options: %w[backlog todo done], trigger_class_name: "min-w-28" },
          { name: "filters[priority]", placeholder: "Priority", options: %w[low medium high], trigger_class_name: "min-w-28" }
        ]
      )
    )

    assert_selector %(input[type="search"][placeholder="Filter tasks..."][value="docs"][disabled])
    assert_selector %(button[disabled]), text: "Search"
    assert_text "Status"
    assert_text "Priority"
  end
end
