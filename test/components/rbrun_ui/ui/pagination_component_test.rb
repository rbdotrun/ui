require "test_helper"

class RbrunUi::Ui::Pagination::ComponentTest < ViewComponent::TestCase
  test "renders reusable pagination controls" do
    render_inline(
      RbrunUi::Ui::Pagination::Component.new(
        total_count: 100,
        rows_per_page: 10,
        page: 1,
        page_count: 10,
        interactive: false
      )
    )

    assert_text "Total of 100 record(s)."
    assert_text "Rows per page"
    assert_text "Page 1 of 10"
    assert_selector %(nav[aria-label="Pagination"])
    assert_selector %(button[disabled]), minimum: 2
  end
end
