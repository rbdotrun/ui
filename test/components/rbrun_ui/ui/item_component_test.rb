require "test_helper"

class RbrunUi::Ui::Item::ComponentTest < ViewComponent::TestCase
  test "renders title only" do
    render_inline(RbrunUi::Ui::Item::Component.new(title: "Workspace Alpha"))

    assert_text "Workspace Alpha"
    assert_no_text "Subtitle"
  end

  test "renders avatar and subtitle" do
    render_inline(
      RbrunUi::Ui::Item::Component.new(
        title: "Alice Johnson",
        subtitle: "alice@example.com",
        avatar: { name: "Alice Johnson" },
        size: :lg
      )
    )

    assert_text "Alice Johnson"
    assert_text "alice@example.com"
    assert_selector %(span[aria-label="Alice Johnson"]), text: "AJ"
    assert_selector %(div.text-base)
    assert_selector %(div.text-sm), text: "alice@example.com"
  end

  test "renders parent-owned leading affordance" do
    render_inline(RbrunUi::Ui::Item::Component.new(
                    title: "Weekly updates",
                    subtitle: "Send every Friday"
                  )) do |item|
      item.with_leading do
        %(<span class="test-leading-box" aria-hidden="true"></span>).html_safe
      end
    end

    assert_text "Weekly updates"
    assert_text "Send every Friday"
    assert_selector %(span.test-leading-box)
  end

  test "renders icon affordance" do
    render_inline(RbrunUi::Ui::Item::Component.new(title: "Profile", icon: "user"))

    assert_text "Profile"
    assert_selector %(svg)
  end
end
