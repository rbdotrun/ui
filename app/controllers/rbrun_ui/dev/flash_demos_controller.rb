module RbrunUi
  module Dev
    class FlashDemosController < RbrunUi::ApplicationController
      before_action :ensure_local_env

      def create_vanilla
        redirect_to showcase_component_path("flash"), notice: "Signed in successfully."
      end

      def create_async
        RbrunUi::Dev::FlashDemoJob.set(wait_until: Time.current + 1.second).perform_later(
          message: "Background sync finished.",
          variant: :notice
        )

        redirect_to showcase_component_path("flash")
      end

      private

        def ensure_local_env
          return if Rails.env.local?

          render plain: "Showcase is only available in dev/test", status: :not_found
        end
    end
  end
end
