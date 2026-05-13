require "test_helper"

class RbrunUi::Ui::Badge::ComponentTest < ViewComponent::TestCase
  test "renders the css-zero style badge pill" do
    render_inline(RbrunUi::Ui::Badge::Component.new(label: "Documentation", tone: :amber))

    assert_text "Documentation"
    assert_selector %(span.inline-flex.whitespace-nowrap.rounded-md.border.px-1\\.5.py-0\\.5.font-mono.text-\\[11px\\]\\/4.font-medium.uppercase.tracking-\\[0\\.025em\\].bg-amber-50.text-amber-700)
  end

  test "uses the shared semantic suite for red badges" do
    render_inline(RbrunUi::Ui::Badge::Component.new(label: "Bug", tone: :red))

    assert_selector %(span.border-rose-200.bg-rose-50.text-rose-700)
  end
end
