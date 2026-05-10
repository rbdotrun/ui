require "test_helper"

class RbrunUi::Ui::Dialog::ComponentTest < ViewComponent::TestCase
  test "renders inline trigger and dialog panel" do
    render_inline(RbrunUi::Ui::Dialog::Component.new(trigger_label: "Open settings")) do |dialog|
      dialog.with_header do |header|
        header.with_left { "Settings" }
        header.with_right { "Close" }
      end

      dialog.with_footer do |footer|
        footer.with_right { "Apply" }
      end

      "Dialog body"
    end

    assert_selector %(div[data-controller="rbrun-ui--dialog"])
    assert_selector %(button), text: "Open settings"
    assert_selector %(div[data-rbrun-ui--dialog-target="backdrop"][hidden]), visible: false
    assert_selector %(div[role="dialog"][aria-modal="true"]), visible: false
    assert_text "Settings"
    assert_text "Dialog body"
    assert_text "Apply"
  end
end
