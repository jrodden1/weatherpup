# WeatherPup

Welcome to WeatherPup!  WeatherPup is a CLI written in Ruby that fetches current weather information based on a user entered US Zip Code or a GPS Coordinate Pair (Latitude and Longitude).  Previously fetched weather conditions can also be viewed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'weatherpup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install weatherpup

## Usage

After running the `weatherpup` executable from the `bin` folder, you'll be presented with a few options.

```
1. Fetch by Zip Code
2. Fetch by GPS Coordinates (Latitude and Longitude)
3. Fetch previously fetched conditions
```

Type in `1` to get the current weather conditions by US Zip Code.  After doing this, you'll be asked to type in the 5 digit zip code.  You'll then be shown the current weather for that zip code.  From there you'll have the option to go `back` to the main menu.

Type in `2` to get the current weather conditions by GPS Coordinates (Latitude and Longitude pair).  After doing this, you'll be asked to type in the _latitude_ in decimal format. Example Latitude in decimal format: `40.705204` 

You'll then be asked to type in the _longitude_ in decimal format. Example Longitude in decimal format: `-74.013845`

Then you'll be shown the current weather for that GPS Coordinate pair.  From there you'll have the option to go `back` to the main menu.

Type in `3` to get a list of the previously fetched weather conditions.  From there you'll have the option to select which previous fetch you would like to view.  Type in the corresponding number then you'll view that historic fetch.  From there you'll have the option to go `back` to the main menu.

To exit the program, if you are not already at the main menu, return to the main menu then type in `exit`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jrodden1/weatherpup.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
