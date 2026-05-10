require "test_helper"

class RbrunUi::Ui::Drawer::ComponentTest < ViewComponent::TestCase
  test "renders inline trigger and drawer panel" do
    render_inline(RbrunUi::Ui::Drawer::Component.new(trigger_label: "Open filters")) do |drawer|
      drawer.with_header do |header|
        header.with_left { "Filters" }
      end

      drawer.with_footer do |footer|
        footer.with_right { "Done" }
      end

      "Drawer body"
    end

    assert_selector %(div[data-controller="rbrun-ui--drawer"])
    assert_selector %(button), text: "Open filters"
    assert_selector %(div[data-rbrun-ui--drawer-target="backdrop"][hidden]), visible: false
    assert_selector %(div[role="dialog"][aria-modal="true"]), visible: false
    assert_includes rendered_content, %(data-rbrun-ui--drawer-target="panel")
    assert_includes rendered_content, %(w-3/4)
    assert_includes rendered_content, %(translate-x-full)
    assert_text "Filters"
    assert_text "Drawer body"
    assert_text "Done"
  end
end
