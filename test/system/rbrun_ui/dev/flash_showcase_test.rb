require "application_system_test_case"

class RbrunUi::Dev::FlashShowcaseTest < ApplicationSystemTestCase
  setup do
    @previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :async
  end

  teardown do
    ActiveJob::Base.queue_adapter = @previous_adapter
  end

  test "vanilla flash button renders a toast after redirect" do
    visit "/_dev/showcase/flash"

    click_button "Vanilla flash"

    assert_current_path "/_dev/showcase/flash"
    assert_selector %[#rbrun-ui-flash-tray article[data-controller="rbrun-ui--flash"]], text: "Signed in successfully.", wait: 5
  end

  test "background job button broadcasts a toast into the tray" do
    visit "/_dev/showcase/flash"

    click_button "Background job flash"

    assert_current_path "/_dev/showcase/flash"
    assert_selector %[#rbrun-ui-flash-tray article[data-controller="rbrun-ui--flash"]], text: "Background sync finished.", wait: 5
  end
end
