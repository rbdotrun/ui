require "test_helper"

class RbrunUi::Ui::Flash::ComponentTest < ViewComponent::TestCase
  test "renders a dismissible toast with flash controller wiring" do
    render_inline(RbrunUi::Ui::Flash::Component.new(
      message: "Please sign in to continue.",
      variant: :alert
    ))

    assert_text "Action needed"
    assert_text "Please sign in to continue."
    assert_selector %(article[data-controller="rbrun-ui--flash"][data-state="closed"][data-rbrun-ui--flash-duration-value="4200"])
    assert_selector %(button[aria-label="Dismiss notification"])
    assert_selector %(section.border-rose-200)
  end

  test "renders a custom duration when provided" do
    render_inline(RbrunUi::Ui::Flash::Component.new(
      message: "Repository imported successfully.",
      variant: :notice,
      duration: 7000
    ))

    assert_selector %(article[data-rbrun-ui--flash-duration-value="7000"])
    assert_text "Repository imported successfully."
  end
end
