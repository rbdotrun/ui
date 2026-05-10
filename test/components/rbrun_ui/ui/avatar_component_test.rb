require "test_helper"

class RbrunUi::Ui::Avatar::ComponentTest < ViewComponent::TestCase
  test "renders initials fallback from the provided name" do
    render_inline(RbrunUi::Ui::Avatar::Component.new(name: "Alice Johnson"))

    assert_selector %(span[aria-label="Alice Johnson"]), text: "AJ"
  end

  test "renders an image when src is provided" do
    render_inline(RbrunUi::Ui::Avatar::Component.new(name: "Alice Johnson", src: "/alice.jpg", size: :lg))

    assert_selector %(img[src="/alice.jpg"][alt="Alice Johnson"])
    assert_selector %(span.h-12.w-12)
  end

  test "uses explicit initials when provided" do
    render_inline(RbrunUi::Ui::Avatar::Component.new(name: "Alice Johnson", initials: "ZZ"))

    assert_selector %(span[aria-label="Alice Johnson"]), text: "ZZ"
  end

  test "renders an icon fallback" do
    render_inline(RbrunUi::Ui::Avatar::Component.new(name: "Updates", icon: "sparkles"))

    assert_selector %(span[aria-label="Updates"] svg)
  end
end
