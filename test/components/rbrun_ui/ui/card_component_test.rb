require "test_helper"

class RbrunUi::Ui::Card::ComponentTest < ViewComponent::TestCase
  test "renders a bordered card using area layout" do
    render_inline(RbrunUi::Ui::Card::Component.new(class_name: "h-64")) do |card|
      card.with_header do
        "Card title"
      end

      card.with_footer do
        "Save"
      end

      "Scrollable content"
    end

    assert_text "Card title"
    assert_text "Scrollable content"
    assert_text "Save"
    assert_selector %(div.rounded-xl.border.border-border.bg-white.shadow-sm.h-64)
    assert_selector %(div.border-b.border-border)
    assert_selector %(div.border-t.border-border)
  end
end
