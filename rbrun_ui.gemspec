require_relative "lib/rbrun_ui/version"

Gem::Specification.new do |spec|
  spec.name        = "rbrun_ui"
  spec.version     = RbrunUi::VERSION
  spec.authors     = ["Benjamin Bonnet"]
  spec.email       = ["benjamin.bonnet@notiplus.com"]

  spec.summary     = "ViewComponent-based UI kit (button, dialog, popover, select, table, …) for Rails apps."
  spec.description = "A Rails Engine shipping ~25 opinionated ViewComponents with Tailwind v4 design " \
                     "tokens, a Stimulus sidecar loader, and Floating UI for popover positioning. " \
                     "Extracted from the rbrun project."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"]    = "https://github.com/notiplus/rbrun_ui"
  spec.metadata["source_code_uri"] = "https://github.com/notiplus/rbrun_ui"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  # Runtime dependencies. Anything required at component-render time
  # belongs here. Host-app concerns (tailwindcss-rails, importmap-rails,
  # stimulus-rails, propshaft) are documented in the README — they are
  # installed by the host's `rails new` and we don't want to fight the
  # host's version pinning.
  spec.add_dependency "rails", ">= 8.1.0"
  spec.add_dependency "view_component"
  spec.add_dependency "view_component-contrib"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "tailwind_merge"
  spec.add_dependency "lucide-rails"
  spec.add_dependency "rouge"  # Ui::Code::Component syntax highlighting

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "selenium-webdriver"
end
