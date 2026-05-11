require "test_helper"

class RbrunUi::Ui::Flash::ComponentTest < ViewComponent::TestCase
  test "renders a dismissible toast with flash controller wiring" do
    render_inline(RbrunUi::Ui::Flash::Component.new(
      message: "Please sign in to continue.",
      variant: :alert
    ))

    assert_text "Action needed"
    assert_text "Please sign in to continue."
    assert_selector %(article[data-controller="rbrun-ui--flash"][data-state="closed"])
    assert_selector %(button[aria-label="Dismiss notification"])
    assert_selector %(section.border-rose-200)
  end
end
