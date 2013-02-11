#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'spree/core/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default => [:spec]

task :test_app do
  %w( spree_landlord ).each do |engine|
    ENV['LIB_NAME'] = File.join(engine)
    ENV['DUMMY_PATH'] = File.expand_path("../../#{engine}/spec/dummy", __FILE__)
    Rake::Task['common:test_app'].execute(Rake::TaskArguments.new([:user_class], ['Spree::User']))

    # copy the test overrides and views into the dummy app
    require 'fileutils'
    FileUtils.cp_r '../assets/dummy_app/views', './app'
    FileUtils.cp_r '../assets/dummy_app/overrides', './app'
    FileUtils.mkdir './app/tenants'
    FileUtils.cp_r '../assets/orange', './app/tenants'
    FileUtils.cp_r '../assets/green', './app/tenants'
    FileUtils.cp_r '../assets/shared', './app/views'
    FileUtils.cp_r '../assets/erborange', './app/tenants'
    FileUtils.cp_r '../assets/hamlorange', './app/tenants'
    FileUtils.cp_r '../assets/defaceorange', './app/tenants'
  end
end
