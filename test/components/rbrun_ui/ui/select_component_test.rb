require "test_helper"

class RbrunUi::Ui::Select::ComponentTest < ViewComponent::TestCase
  test "renders grouped searchable multi-select with footer action" do
    render_inline(
      RbrunUi::Ui::Select::Component.new(
        name: "filters[assignees]",
        multiple: true,
        searchable: true,
        placeholder: "Pick teammates…",
        value: %w[alice claire],
        groups: [
          { label: "Engineering", options: [["Alice", "alice"], ["Bob", "bob"]] },
          { label: "Design", options: [["Claire", "claire"], ["Drew", "drew"]] }
        ],
        footer_action: { label: "Add teammate", href: "/people/new" }
      )
    )

    assert_selector %(input[type="search"][placeholder="Search…"]), visible: false
    assert_selector %(div[role="listbox"][aria-multiselectable="true"]), visible: false
    assert_includes rendered_content, "Engineering"
    assert_includes rendered_content, "Design"
    assert_selector %(input[type="hidden"][name="filters[assignees][]"][value="alice"]), count: 1, visible: false
    assert_selector %(input[type="hidden"][name="filters[assignees][]"][value="claire"]), count: 1, visible: false
    assert_selector %(button[role="option"][aria-selected="true"]), count: 2, visible: false
    assert_selector %(a[href="/people/new"]), text: "Add teammate", visible: false
    assert_text "Alice, Claire"
  end

  test "uses stronger selected background without checkbox by default" do
    render_inline(
      RbrunUi::Ui::Select::Component.new(
        name: "priority",
        value: "medium",
        options: [%w[Low low], %w[Medium medium], %w[High high]]
      )
    )

    assert_selector %(button[role="option"][aria-selected="true"].bg-stone-200\\/70), count: 1, visible: false
    refute_includes rendered_content, "opacity-0"
  end

  test "renders persistent checkbox column when enabled" do
    render_inline(
      RbrunUi::Ui::Select::Component.new(
        name: "priority",
        value: "medium",
        with_checkbox: true,
        options: [%w[Low low], %w[Medium medium], %w[High high]]
      )
    )

    assert_selector %(button[role="option"][aria-selected="true"].bg-stone-100\\/60), count: 1, visible: false
    assert_includes rendered_content, "opacity-0"
    assert_includes rendered_content, "opacity-100"
  end
end
