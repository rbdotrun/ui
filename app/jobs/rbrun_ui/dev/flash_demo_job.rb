module RbrunUi
  module Dev
    class FlashDemoJob < ActiveJob::Base
      queue_as :default

      def perform(message:, variant: :info, duration: RbrunUi::Ui::Flash::Component::DEFAULT_DURATION)
        Turbo::StreamsChannel.broadcast_append_to(
          "rbrun-ui-flash-demo",
          target: "rbrun-ui-flash-demo-tray",
          partial: "rbrun_ui/shared/flash",
          locals: {
            type: variant,
            message:,
            duration:
          }
        )
      end
    end
  end
end
