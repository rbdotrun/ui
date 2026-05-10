require "test_helper"

class RbrunUi::Ui::Badge::ComponentTest < ViewComponent::TestCase
  test "renders the css-zero style badge pill" do
    render_inline(RbrunUi::Ui::Badge::Component.new(label: "Documentation", tone: :amber))

    assert_text "Documentation"
    assert_selector %(span.inline-flex.rounded-full.border.bg-amber-50.text-amber-700)
  end
end
