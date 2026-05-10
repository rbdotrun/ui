ENV["RAILS_ENV"] ||= "test"

require_relative "dummy/config/environment"
require "rails/test_help"

# ViewComponent test base class — gives us `render_inline` + Capybara
# matchers (`assert_selector`, `assert_text`, …).
require "view_component/test_case"
