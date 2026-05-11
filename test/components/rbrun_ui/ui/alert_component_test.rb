require "test_helper"

class RbrunUi::Ui::Alert::ComponentTest < ViewComponent::TestCase
  test "renders title, message, and variant styling" do
    render_inline(RbrunUi::Ui::Alert::Component.new(
      title: "Sign-in required",
      message: "Please sign in to continue.",
      variant: :danger
    ))

    assert_text "Sign-in required"
    assert_text "Please sign in to continue."
    assert_selector %(section.border-rose-200.bg-rose-50\\/90)
    assert_selector %(svg.text-rose-600)
  end
end
