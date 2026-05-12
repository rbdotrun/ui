require "test_helper"

class RbrunUi::Dev::FlashDemoJobTest < ActiveJob::TestCase
  test "broadcasts a flash toast into the demo tray" do
    broadcast = nil

    channel = Turbo::StreamsChannel.singleton_class
    original = Turbo::StreamsChannel.method(:broadcast_append_to)

    channel.define_method(:broadcast_append_to) do |*args, **kwargs|
      broadcast = [args, kwargs]
    end

    begin
      RbrunUi::Dev::FlashDemoJob.perform_now(message: "Background sync finished.", variant: :notice, duration: 7000)
    ensure
      channel.define_method(:broadcast_append_to, original)
    end

    assert_equal ["rbrun-ui-flash-demo"], broadcast[0]
    assert_equal "rbrun-ui-flash-demo-tray", broadcast[1][:target]
    assert_equal "rbrun_ui/shared/flash", broadcast[1][:partial]
    assert_equal :notice, broadcast[1][:locals][:type]
    assert_equal "Background sync finished.", broadcast[1][:locals][:message]
    assert_equal 7000, broadcast[1][:locals][:duration]
  end
end
