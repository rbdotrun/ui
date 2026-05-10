require "test_helper"

class RbrunUi::Ui::Menu::ComponentTest < ViewComponent::TestCase
  test "renders configured items from the builder block" do
    render_inline(
      RbrunUi::Ui::Menu::Component.new(
        searchable: true,
        footer_action: { label: "Add item", href: "/items/new" }
      )
    ) do |menu|
      menu.header "Signed in as Ben"
      menu.link "Profile", href: "/profile", icon: "user"
      menu.link "Settings", href: "/settings", icon: "settings"
      menu.separator
      menu.button "Sign out", href: "/session", method: :delete, icon: "log-out"
    end

    assert_selector %(div[role="menu"])
    assert_text "Signed in as Ben"
    assert_link "Profile", href: "/profile"
    assert_link "Settings", href: "/settings"
    assert_selector %(hr[role="separator"])
    assert_selector %(form[action="/session"] button[role="menuitem"]), text: "Sign out"
    assert_selector %(input[type="search"][placeholder="Search…"])
    assert_link "Add item", href: "/items/new"
  end
end
