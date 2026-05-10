module RbrunUi
  module Dev
    # Visual QA destination. One section per component the design system
    # ships. Mounted only when `Rails.env.local?` (dev + test).
    #
    # Inherits from `RbrunUi::ApplicationController` (engine-internal
    # base), which sets `layout "rbrun_ui/application"` — so the
    # showcase renders inside the engine's layout, gets the engine's
    # importmap and CSS, and is fully isolated from whatever the host
    # has wired into its own ::ApplicationController.
    class ShowcaseController < RbrunUi::ApplicationController
      # `RbrunUi::ApplicationHelper` (which provides `ui("name", …)`)
      # is auto-included into every controller by the engine's
      # `rbrun_ui.helpers` initializer. `ShowcaseHelper` is engine-
      # scoped — it's auto-discovered by Rails because we inherit from
      # the engine's namespaced ApplicationController.

      before_action :ensure_local_env

      def index
        # Renders app/views/rbrun_ui/dev/showcase/index.html.erb, which
        # composes every component partial in this directory.
      end

      def show
        @component = params[:component]
        # Allow direct linking to a single component's section when
        # the page gets too long. Renders the same index; the partials
        # are stable anchor targets.
        render :index
      end

      private

        def ensure_local_env
          return if Rails.env.local?

          render plain: "Showcase is only available in dev/test", status: :not_found
        end
    end
  end
end
