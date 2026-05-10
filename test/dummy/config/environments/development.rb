require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.server_timing = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = :all

  config.active_support.deprecation = :log

  # Allow any host so smoke tests via Integration::Session and a casual
  # `bin/dev` boot don't trip Rails' host-authorization. The dummy app
  # is never deployed.
  config.hosts.clear
end
