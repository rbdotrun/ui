require "test_helper"

# Integration coverage for the engine's mounted showcase route. This
# is the only test that boots through the full Rack stack — every
# component test renders ViewComponents in isolation. So this is also
# our regression guard for:
#
#   - Importmap merge: the page only renders if the engine's importmap
#     has been merged into the host's, otherwise <%= javascript_importmap_tags %>
#     blows up looking for the floating-ui pin (popover swatch).
#   - Helper isolation: `component()` and `swatch_source_for_caller`
#     come from RbrunUi::ComponentsHelper / RbrunUi::ShowcaseHelper,
#     which are explicitly helper'd in by ShowcaseController. If that
#     wiring breaks, the index render raises NoMethodError.
#   - Cross-component rendering: every showcase partial composes a
#     non-trivial subset of the component graph, so a missing autoload
#     or constant typo anywhere surfaces as a 500 here.
class RbrunUi::Dev::ShowcaseControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "GET /_dev/showcase renders 200 and includes every component section" do
    get "/_dev/showcase"

    assert_response :ok

    body = @response.body

    %w[Button Avatar Badge Alert Flash Item Popover Menu Select Card Table Dialog Drawer].each do |section|
      assert_includes body, ">#{section}</h2>",
                      "expected showcase index to render an <h2> for #{section}"
    end

    assert_includes body, "Inline flash"
    assert_includes body, "Background job flash"
  end

  test "GET /_dev/showcase/:component renders the same index" do
    # Anchor-link target. Same index content; the show action is just
    # a stable URL for direct links into a section.
    get "/_dev/showcase/button"

    assert_response :ok
    assert_includes @response.body, "Component showcase"
  end

  test "POST /_dev/showcase/flash-demo/vanilla responds with a turbo_stream appending the flash" do
    post "/_dev/showcase/flash-demo/vanilla", as: :turbo_stream

    assert_response :ok
    assert_equal Mime[:turbo_stream].to_s, @response.media_type
    assert_includes @response.body, "Signed in successfully."
    assert_includes @response.body, 'data-controller="rbrun-ui--flash"'
    assert_includes @response.body, 'target="rbrun-ui-flash-demo-tray"'
  end

  test "POST /_dev/showcase/flash-demo/async enqueues a broadcast job and responds 204" do
    assert_enqueued_with(job: RbrunUi::Dev::FlashDemoJob) do
      post "/_dev/showcase/flash-demo/async", as: :turbo_stream
    end

    assert_response :no_content
  end
end
