require 'rake'
require 'rake/clean'
require "bundler/gem_tasks"
require 'middleman-core'


## cucumber

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  ENV["TEST"] = "true"

  exempt_tags = ""
  exempt_tags << "--tags ~@nojava " if RUBY_PLATFORM == "java"
  exempt_tags << "--tags ~@three_one " unless ::Middleman::VERSION.match(/^3\.1\./)

  t.cucumber_opts = "--color --tags ~@wip #{exempt_tags} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

desc "Run tests, Cucumber"
task :test => [:cucumber]


## rubocop
require 'rubocop/rake_task'
desc "Run rubocop"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = false
end



