require "test_helper"

class RbrunUi::Ui::Area::ComponentTest < ViewComponent::TestCase
  test "renders fixed header footer and scrollable body" do
    render_inline(RbrunUi::Ui::Area::Component.new) do |area|
      area.with_header { "Header" }
      area.with_footer { "Footer" }
      "Body"
    end

    assert_text "Header"
    assert_text "Body"
    assert_text "Footer"
    assert_selector %(div.flex.h-full.min-h-0.flex-col.overflow-hidden)
    assert_selector %(div.flex.min-h-0.flex-1.flex-col.overflow-y-auto), text: "Body"
  end
end
