require_relative "boot"

require "rails"
# Pick the frameworks the dummy app actually needs. Skipping Action
# Mailer / Action Mailbox / Action Text / Action Cable / Active Storage
# keeps boot fast for the component test suite — they're not required
# to render a ViewComponent or assert against the rendered HTML.
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_cable/engine"
require "action_view/railtie"
require "rails/test_unit/railtie"

require "propshaft"
require "importmap-rails"
require "stimulus-rails"
require "turbo-rails"
require "tailwindcss-rails"

require "rbrun_ui"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.root = File.expand_path("..", __dir__)

    config.eager_load = false
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false
    config.active_job.queue_adapter = Rails.env.test? ? :test : :async

    # Quiet boot — the test suite renders ViewComponents and doesn't
    # care about logger output.
    config.logger = ActiveSupport::Logger.new(IO::NULL)

    # The engine is auto-mounted via its `isolate_namespace`, but the
    # dummy app pulls in nothing else that would conflict.
  end
end
