#need to create an environment file to clean this up later??
require_relative "./weatherpup/version"
require_relative "./weatherpup/cli"
require_relative "./weatherpup/current_conditions"

require 'httparty'
require 'yaml'
require 'pry'

VALID_US_ZIP_CODES = YAML.load(File.read("./lib/weatherpup/valid_us_zip_codes.yml"))
