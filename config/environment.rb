# Load the Rails application.
require File.expand_path('../application', __FILE__)
require "yaml"
$funny_names = YAML.load_file('config/names.yml')

# Initialize the Rails application.
Fremote::Application.initialize!
