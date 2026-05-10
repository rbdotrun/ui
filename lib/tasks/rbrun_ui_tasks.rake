# Engine-internal Tailwind build tasks. The gem ships a precompiled
# `app/assets/stylesheets/rbrun_ui/tailwind.css` so engine pages
# work without the host running anything; these tasks are how that
# precompiled file is regenerated when the engine's component
# templates or design tokens change.
#
# Source:  app/assets/stylesheets/rbrun_ui/engine.css
# Output:  app/assets/stylesheets/rbrun_ui/tailwind.css
#
# Run from the engine repo root:
#   bin/rake rbrun_ui:tailwind_build  # one-off compile
#   bin/rake rbrun_ui:tailwind_watch  # rebuild on change (dev)

namespace :rbrun_ui do
  desc "Compile the engine's Tailwind input into the shipped tailwind.css bundle"
  task tailwind_build: :environment do
    require "tailwindcss-rails"

    input  = RbrunUi::Engine.root.join("app/assets/stylesheets/rbrun_ui/engine.css").to_s
    output = RbrunUi::Engine.root.join("app/assets/stylesheets/rbrun_ui/tailwind.css").to_s

    command = [Tailwindcss::Commands.compile_command.first, "-i", input, "-o", output]

    puts "Building rbrun_ui Tailwind CSS"
    puts "  input:  #{input}"
    puts "  output: #{output}"
    system(*command)
    puts "Done."
  end

  desc "Watch the engine's component tree and recompile tailwind.css on change"
  task tailwind_watch: :environment do
    require "tailwindcss-rails"

    input  = RbrunUi::Engine.root.join("app/assets/stylesheets/rbrun_ui/engine.css").to_s
    output = RbrunUi::Engine.root.join("app/assets/stylesheets/rbrun_ui/tailwind.css").to_s

    command = [Tailwindcss::Commands.compile_command.first, "-i", input, "-o", output, "--watch"]

    puts "Watching rbrun_ui sources for Tailwind rebuild…"
    system(*command)
  end
end
