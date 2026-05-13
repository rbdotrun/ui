require "test_helper"

class RbrunUi::Ui::ButtonComponentTest < ViewComponent::TestCase
  test "white variant uses white fill and border" do
    render_inline(RbrunUi::Ui::Button::Component.new(label: "Workspace", variant: :white))

    assert_selector "button.bg-white.border.border-border.text-stone-900", text: "Workspace"
  end
end
