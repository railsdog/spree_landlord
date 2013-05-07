# move support/test_app_fixtures tree into spec/dummy
require 'fileutils'
FileUtils.cp_r './spec/test_app_fixtures/.','./spec/dummy'
# so these get added to the lookup path
# if we don't do this and dynamically create compiled views
# during our tests, it is too late; deface has already initialized
FileUtils.mkdir_p './spec/dummy/app/compiled_views' 

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'ffaker'
require 'deface'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in spree_core
require 'spree/core/testing_support/factories'
require 'spree/core/testing_support/authorization_helpers'
require 'spree/core/url_helpers'
require 'spree/core/testing_support/flash'
require 'spree/core/testing_support/preferences'
require 'spree/core/testing_support/controller_requests'

require File.dirname(__FILE__) + "/factories"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::Core::UrlHelpers
  config.include Spree::Core::TestingSupport::Flash
  config.include Spree::Core::TestingSupport::Preferences
  config.include Spree::Core::TestingSupport::ControllerRequests, :type => :controller

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:each) do
    Thread.current[:tenant_id] = nil
  end
end
