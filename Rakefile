require "bundler/setup"
require "bundler/gem_tasks"

require "rake/testtask"

# We deliberately do NOT `load "rails/tasks/engine.rake"` here. That
# helper redefines the `test` task to run against the dummy app
# (`Dummy::Application`'s test/ directory) rather than our gem's own
# test/ directory — so `rake test` finds 0 files. Loading the dummy
# app's environment happens inside `test/test_helper.rb`, which is
# all we need: minitest discovers the engine's tests via the pattern
# below and runs them against the booted dummy app.
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
  t.verbose = false
end

task default: :test
