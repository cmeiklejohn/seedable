# encoding: UTF-8

ENV["RAILS_ENV"] ||= "test"

PROJECT_ROOT = File.expand_path("../..", __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, "lib")

require 'simplecov'
SimpleCov.start

require 'rails/all'
Bundler.require

require 'rails/test_help'
require 'rspec/rails'
require 'factory_girl_rails'
require 'timecop'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML::load_file(File.dirname(__FILE__) + '/database.yml')
ActiveRecord::Base.establish_connection(ENV['DB'])

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
 
  load(File.dirname(__FILE__) + '/../db/schema.rb')
  load(File.dirname(__FILE__) + '/support/models.rb')
  load(File.dirname(__FILE__) + '/support/factories.rb')
end

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.backtrace_clean_patterns << %r{gems/}
end
