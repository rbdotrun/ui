require "test_helper"

class RbrunUi::Ui::Table::ComponentTest < ViewComponent::TestCase
  test "renders nested filters rows and pagination" do
    render_inline(RbrunUi::Ui::Table::Component.new) do |table|
      table.filters do
        "Filters go here"
      end

      table.header do |header|
        header.cell(class_name: "w-12") { table.select_all_checkbox(disabled: true) }
        header.cell(label: "Task")
        header.cell(label: "Title", sortable: true, interactive: false)
        header.cell(label: "Status", sortable: true, interactive: false)
        header.cell(label: "Priority", sortable: true, interactive: false)
        header.cell(class_name: "w-14")
      end

      table.row do |row|
        row.cell { table.row_checkbox(value: "35178780", disabled: true) }
        row.cell(class_name: "whitespace-nowrap font-medium text-stone-500") { "35178780" }
        row.cell(class_name: "min-w-[28rem]") { "Try to hack the HEX alarm, maybe it will connect the optical pixel!" }
        row.cell(class_name: "whitespace-nowrap") { "In progress" }
        row.cell(class_name: "whitespace-nowrap") { "Medium" }
        row.cell(class_name: "whitespace-nowrap text-right") { "Open menu" }
      end

      table.batch do
        "Batch actions"
      end

      table.paginate([1, 2, 3], total_count: 100, rows_per_page: 10, page: 1, page_count: 10, interactive: false)
    end

    assert_text "Filters go here"
    assert_selector %(div[data-controller="rbrun-ui--table"] table)
    assert_text "Task"
    assert_text "Title"
    assert_text "Status"
    assert_text "Priority"
    assert_selector %(th button.uppercase), minimum: 1
    assert_text "In progress"
    assert_text "Medium"
    assert_selector %(input[data-rbrun-ui--table-target="toggleAll"][type="checkbox"][disabled])
    assert_selector %(input[data-rbrun-ui--table-target="checkbox"][type="checkbox"][disabled])
    assert_selector %(div[data-rbrun-ui--table-target="batchDock"].hidden)
    assert_text "Batch actions"
    assert_text "Total of 100 record(s)."
    assert_text "Page 1 of 10"
    assert_selector %(button[disabled]), minimum: 1
  end
end
