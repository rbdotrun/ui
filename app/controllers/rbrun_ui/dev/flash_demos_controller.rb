module RbrunUi
  module Dev
    class FlashDemosController < RbrunUi::ApplicationController
      before_action :ensure_local_env

      # Synchronous: respond with a Turbo Stream that appends the flash
      # partial to the showcase toast tray. No redirect, no full-page
      # refresh — the toast appears the moment the response arrives.
      def create_vanilla
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.append(
              "rbrun-ui-flash-demo-tray",
              partial: "rbrun_ui/shared/flash",
              locals: {
                type: :notice,
                message: "Signed in successfully.",
                duration: RbrunUi::Ui::Flash::Component::DEFAULT_DURATION
              }
            )
          end
        end
      end

      # Async: enqueue a background job that broadcasts via
      # `Turbo::StreamsChannel` into the same toast tray ~1 s later.
      # The controller's response itself is empty (`head :no_content`)
      # so the click doesn't trigger any DOM change; the toast arrives
      # via the page's `turbo_stream_from "rbrun-ui-flash-demo"`
      # subscription declared in the shared flash_stack partial.
      def create_async
        RbrunUi::Dev::FlashDemoJob.set(wait_until: Time.current + 1.second).perform_later(
          message: "Background sync finished.",
          variant: :notice
        )

        respond_to do |format|
          format.turbo_stream { head :no_content }
        end
      end

      private

        def ensure_local_env
          return if Rails.env.local?

          render plain: "Showcase is only available in dev/test", status: :not_found
        end
    end
  end
end
