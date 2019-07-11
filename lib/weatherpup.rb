#need to create an environment file to clean this up later??
require_relative "./weatherpup/version"
require_relative "./weatherpup/cli"
require_relative "./weatherpup/weather_conditions"

require 'httparty'
require 'colorize'
require 'yaml'
require 'pry'

VALID_US_ZIP_CODES = YAML.load(File.read("./lib/weatherpup/valid_us_zip_codes.yml"))
APPID = "e4ece4d3cbcfdd05d69889c6753d57da"

#These are the ranges that will allow me to figure out the direction indicator is when I get back information from the weather API for the wind direction in degrees
NORTH_RANGE_PART1 = 338..360
NORTH_RANGE_PART2 = 0..22
NORTHEAST_RANGE = 23..67
EAST_RANGE = 68..112
SOUTHEAST_RANGE = 113..157
SOUTH_RANGE = 158..202
SOUTHWEST_RANGE = 203..247
WEST_RANGE = 248..292
NORTHWEST_RANGE = 293..337

#These are the ranges that will allow me to validate if a lat or long value is valid
VALID_LAT_RANGE = -90.0..90.0
VALID_LONG_RANGE = -180.0..180.0