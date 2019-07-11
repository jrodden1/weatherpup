class WeatherPup::WeatherConditions
   attr_accessor :reading_date_and_time, :current_conditions_means, :zip_code, :lat, :long, 
                 :temperature, :pressure, :humidity, :current_weather_description, :pressure, 
                 :wind_speed, :wind_direction_indicator, :wind_direction_indicator_string, :reading_date_and_time, 
                 :city_name, :when_fetched
   #With this class I should be able to create a WeatherConditions instance by Zip code or GPS coordinates

   @@all = []

   def initialize
      @@all << self
   end
   
   def self.all
      @@all
   end

   def zip_api_fetch(zip_code, country_code = "us")
      #this will actually hit the OpenWeatherMap Api
      #I have defaulted the country code to US for now, but have built the GET request to be flexible to add multi-country postal codes later
      HTTParty.get("https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},#{country_code}&APPID=#{APPID}&units=imperial")
   end

   def zip_process_api_data_to_attribs_hash(api_data)
      #May want to separate out this wind direction checker or completely wipe out the wind direction information all together for GPS feature
      #REFACTOR: take out the line below and rename the arg to api_info
      api_info = api_data
      wind_direction_indicator_deg = api_info["wind"]["deg"].round
      wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg)

      #creates attributes_hash_for_mass_assignment to be used by the #write_attributes method
      {
         :current_weather_description => api_info["weather"][0]["main"],
         #I'm leaving :current_condtions_means in here in case I want to combine my print_gps and print_zip methods, otherwise, it's not needed at the moment
         :current_conditions_means => "Zip Code",
         :temperature => api_info["main"]["temp"].round.to_s,
         :humidity => api_info["main"]["humidity"].to_s,
         :pressure => (api_info["main"]["pressure"] * 0.0295300).to_s[0..4],
         :wind_speed => api_info["wind"]["speed"].round.to_s,
         :wind_direction_indicator => wind_direction_indicator_deg.to_s + "°",
         :wind_direction_indicator_string => wind_direction_indicator_string,
         :reading_date_and_time => Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z"),
         :city_name => api_info["name"],
         :when_fetched => Time.now.to_datetime.strftime("%I:%M:%S%P (%b %d)")
      }
   end   

   def gps_api_fetch(latitude, longitude)
      
      #I think I want to split this out into two methods -- #gps_api_data_fetch which will just do the fetch based on the Lat, Longs given to it.  Then have another method, #create_api_data_hash that will do the rest of this in another method.  The #create_api_data_hash method will need to be run in the #new_by_gps method and the create_api_data_hash method will call the #gps_apa_data_fetch method and save that into a variable called api_info 

      #this will actually hit the OpenWeatherMap Api and then return all the information 
      HTTParty.get("https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&APPID=#{APPID}&units=imperial")
   end

   def gps_process_api_data_to_attribs_hash(api_data)
      #May want to separate out this wind direction checker or completely wipe out the wind direction information all together for GPS feature
      
      api_info = api_data
      wind_direction_indicator_deg = api_info["wind"]["deg"]
      if wind_direction_indicator_deg.nil?
         wind_direction_indicator_deg = "No Data"
         wind_direction_indicator_string = ""
      else
         wind_direction_indicator_deg_rounded = wind_direction_indicator_deg.round
         wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg_rounded)
         wind_direction_indicator_deg = wind_direction_indicator_deg.round.to_s + "°"
      end
      #NOTE: REFACTOR Needed / Bug -- if you do another city I need to localize the time to that location's time zone - especially for sunrise and sunset

      #creates attributes_hash_for_mass_assignment to be used by the #write_attributes method
      {
         :current_weather_description => api_info["weather"][0]["main"],
         #I'm leaving :current_condtions_means in here in case I want to combine my print_gps and print_zip methods, otherwise, it's not needed at the moment
         :current_conditions_means => "GPS Coordinates",
         :lat => api_info["coord"]["lat"].to_s,
         :long => api_info["coord"]["lon"].to_s,
         :temperature => api_info["main"]["temp"].round.to_s,
         :humidity => api_info["main"]["humidity"].to_s,
         :pressure => (api_info["main"]["pressure"] * 0.0295300).to_s[0..4],
         :wind_speed => api_info["wind"]["speed"].round.to_s,
         :wind_direction_indicator => wind_direction_indicator_deg,
         :wind_direction_indicator_string => wind_direction_indicator_string,
         :reading_date_and_time => Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z"),
         :city_name => api_info["name"],
         :when_fetched => Time.now.to_datetime.strftime("%I:%M:%S%P (%b %d)")
      }
   end

   def write_attributes(processed_api_data_hash)
      #this will take whatever the API hash was and create attributes for the object that it's run on.
      processed_api_data_hash.map do |key, value|
         self.send("#{key}=", value)
      end
   end   

   def print_zip_conditions
      puts <<~CONDITIONS
         \nThe weather conditions for #{self.city_name.colorize(:green).underline} (#{self.zip_code.colorize(:green)}):  
         
         #{self.temperature.colorize(:light_blue)}°F  
         #{self.humidity.colorize(:light_blue)}% Humidity
         #{self.current_weather_description.colorize(:light_blue)}

         Pressure: #{self.pressure.colorize(:light_blue)} in of Hg
         Wind Speed: #{self.wind_speed.colorize(:light_blue)} MPH 
         Wind Direction: #{self.wind_direction_indicator_string.colorize(:light_blue)} (#{self.wind_direction_indicator.to_s.colorize(:blue)})

         This data is based on the weather station reading time of:
         #{self.reading_date_and_time.colorize(:green)}

         **Weather Data provided by OpenWeatherMap.org**
            **Zip Code data courtesy of AggData.com**
      CONDITIONS
   end

   def print_gps_conditions
      puts <<~CONDITIONS
         \nThe weather conditions for #{self.lat.colorize(:green)}, #{self.long.colorize(:green)} (#{self.city_name.colorize(:green)}):  
         
         #{self.temperature.colorize(:light_blue)}°F  
         #{self.humidity.colorize(:light_blue)}% Humidity
         #{self.current_weather_description.colorize(:light_blue)}

         Pressure: #{self.pressure.colorize(:light_blue)} in of Hg
         Wind Speed: #{self.wind_speed.colorize(:light_blue)} MPH 
         Wind Direction: #{self.wind_direction_indicator_string.colorize(:light_blue)} (#{self.wind_direction_indicator.colorize(:light_blue)})

         This data is based on the weather station reading time of:
         #{self.reading_date_and_time.colorize(:green)}

         **Weather Data provided by OpenWeatherMap.org**
      CONDITIONS
   end
      
   def wind_direction_indicator_to_text(wind_direction_in_degrees)
      #This code may be a little smelly.  I may be able to do this by iterating over a hash of the constants and check wind_direction_in_degrees agains the value of each then return the key.  Meh... not sure. 
      indicator = nil
      if NORTH_RANGE_PART1.member?(wind_direction_in_degrees) || NORTH_RANGE_PART2.member?(wind_direction_in_degrees)
         indicator = "N"
      elsif NORTHEAST_RANGE.member?(wind_direction_in_degrees)
         indicator = "NE"
      elsif EAST_RANGE.member?(wind_direction_in_degrees)
         indicator = "E"
      elsif SOUTHEAST_RANGE.member?(wind_direction_in_degrees)
         indicator = "SE"
      elsif SOUTH_RANGE.member?(wind_direction_in_degrees)
         indicator = "S"
      elsif SOUTHWEST_RANGE.member?(wind_direction_in_degrees)
         indicator = "SW"
      elsif WEST_RANGE.member?(wind_direction_in_degrees)
         indicator = "W"
      elsif NORTHWEST_RANGE.member?(wind_direction_in_degrees)
         indicator = "NW"
      end
      indicator
   end 
end