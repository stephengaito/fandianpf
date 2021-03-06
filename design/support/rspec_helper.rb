# This is the spec_helper used for RSpec specifications which use the 
# Rack stack.

if not defined?(PADRINO_ENV) then
  # specifies to the system which type of environment is being run: 
  # development, test or production.
  #
  PADRINO_ENV = 'test' 
end

# We boot the sytem (including starting the database connection) BUT we 
# do not Padrino.run! the server
#
require File.expand_path(File.dirname(__FILE__) + "/../../config/boot")

require 'fandianpf';

require 'fandianpf/utils/options';

RSpec.configure do |conf|
  conf.mock_with :rspec
  conf.include Rack::Test::Methods
end

# The following code, taken from Capybara/Cucumber, allows the use of 
# feature as a (super)alias of RSpec's describe.
#
def feature(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:capybara_feature] = true
  options[:type] = :feature
  options[:caller] ||= caller
  args.push(options)

  describe(*args, &block)
end

# The following code could be used instead of the Capybara/Cucumber 
# "feature" definition (above) to implement "feature" and "sceneario" 
# as aliases of "describe" and "it" respectively.
#
#module RSpec
#  module Core
#    module DSL
#      alias_method :feature, :describe
#    end
#    class ExampleGroup
#      class << self 
#        define_example_method :scenario
#      end
#    end
#  end
#end

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app Fandianpf::App
#   app Fandianpf::App.tap { |a| }
#   app(Fandianpf::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end

# Ensure we setup Capybara...
#
Capybara.run_server = false;
Capybara.app = app;
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :browser => :chrome)
end

# Rack based DSL helper to issue the http request to 'get' a JSON 
# object.
#
# @param [String] url The requested url
# @return not specified
def getJson(url)
  get(url, 
      {}, 
      { 'HTTP_ACCEPT' => "application/json" });
end

# Rack based DSL helper to return the last response as a ruby object.
#
# @param [String] url The requested url
# @return [Object] the JSON content as a Ruby object 
#   (Hashes will have their keys symbolized).
def lastResponseAsJsonObj
  jsonContent = JSON.parse( last_response.body )
  Fandianpf::Utils::Options.toSymbolHash(jsonContent);
  jsonContent
end

# Rack based DSL helper to issue the http request to 'post' a JSON 
# object.
#
# @param [String] url The requested url
# @param [Object] jsonContent The JSON object
# @return not specified
def postJson(url, jsonContent)
  post(url, 
       jsonContent.to_json, 
       { 'Content-type' => 'application/json'});
end

# Rack based DSL helper to issue the http request to 'put' a JSON 
# object.
#
# @param [String] url The requested url
# @param [Object] jsonContent The JSON object
# @return not specified
def putJson(url, jsonContent)
  put(url, 
      jsonContent.to_json, 
      { 'Content-type' => 'application/json'});
end


# Turn of or off RSpec logging
#
# @param [Boolean] loggingOn whether or not to log rspec information
# @return not specified
def setRSpecLogging(loggingOn, fileName = nil)
  $rSpecLogging = loggingOn;
#  unless fileName.nil? then
#    fileName.sub!(/^.*fandianpf\//,'') 
#    puts "RSpecLogging: #{loggingOn} in #{fileName}";
#  end
end

# Returns the current state of RSpecLogging.
#
# @return [Boolean] the current state of RSpecLogging
def rSpecLogging
  $rSpecLogging
end
  
