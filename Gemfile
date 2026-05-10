source "https://rubygems.org"

# Specify your gem's dependencies in rbrun_ui.gemspec.
gemspec

# Host-side asset pipeline pieces. The gemspec doesn't depend on these
# (a host app pins its own versions through `rails new`), but they're
# required to boot the test/dummy app, so they're declared here.
gem "propshaft"
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tailwindcss-rails"
gem "puma"
gem "sqlite3"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end
