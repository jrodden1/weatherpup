class WeatherPup::WeatherConditions
   attr_accessor :reading_date_and_time, :current_conditions_means, :zip_code, :lat, :long, 
                 :temperature, :pressure, :humidity, :current_weather_description, :pressure, 
                 :wind_speed, :wind_direction_indicator, :wind_direction_indicator_string, :reading_date_and_time, 
                 :city_name, :when_fetched
   #With this class I should be able to create a WeatherConditions instance by Zip code or GPS coordinates.  Also I should be able to list out all the previous WeatherConditions instances that I have.

   #WeatherConditions instance tracker array class variable
   @@all = []

   #Adds the current WeatherConditions instance to the @@all instance tracker
   def initialize
      @@all << self
   end
   
   #Class method used to read the all the instances of WeatherConditions in existence.
   def self.all
      @@all
   end

   #Go actually hit the OpenWeatherMap Api and then return all the information 
   def zip_api_fetch(zip_code, country_code = "us")
      #this will actually hit the OpenWeatherMap Api
      #I have defaulted the country code to US for now, but have built the GET request to be flexible to add multi-country postal codes later
      HTTParty.get("https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},#{country_code}&APPID=#{APPID}&units=imperial")
   end

   #Process the raw API data that was grabbed by #zip_api_fetch and and output a hash that will be used by #write_attributes to mass assign WeatherConditions instance attributes
   def zip_process_api_data_to_attribs_hash(api_info)
      #massage the wind_direction information before writing it to the attributes hash.
      wind_direction_indicator_deg = api_info["wind"]["deg"].round
      wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg)

      #creates attributes hash for mass assignment to be used by the #write_attributes method
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

   #Go actually hit the OpenWeatherMap Api and then return all the information 
   def gps_api_fetch(latitude, longitude)
      
      HTTParty.get("https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&APPID=#{APPID}&units=imperial")
   end

   #Process the raw API data that was grabbed by #gps_api_fetch and and output a hash that will be used by #write_attributes to mass assign WeatherConditions instance attributes
   def gps_process_api_data_to_attribs_hash(api_info)
      #the data from the API for Wind direction for a GPS check is not as reliable and sometimes is missing.
      #Check to see if the data is there first, then write it out the variables used in the hash
      wind_direction_indicator_deg = api_info["wind"]["deg"]
      if wind_direction_indicator_deg.nil?
         wind_direction_indicator_deg = "No Data"
         wind_direction_indicator_string = ""
      else
         wind_direction_indicator_deg_rounded = wind_direction_indicator_deg.round
         wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg_rounded)
         wind_direction_indicator_deg = wind_direction_indicator_deg.round.to_s + "°"
      end

      #creates attributes hash for mass assignment to be used by the #write_attributes method
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

   #Writes attributes using mass assignment to the WeatherConditions object it is called on when given a processed api hash as an arg.
   def write_attributes(processed_api_data_hash)
      processed_api_data_hash.map do |key, value|
         self.send("#{key}=", value)
      end
   end   

   #Prints Zip Conditions to screen from a WeatherConditions Object. 
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

   #Prints GPS conditions to screen from a WeatherConditions object. 
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
   
   #This method figures out what the direction indicator text should when given a numeric wind direction in degrees
   def wind_direction_indicator_to_text(wind_direction_in_degrees)
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

   #This method prints a list out all the instances of WeatherConditions to screen
   def self.list_all_previous
      self.all.each.with_index(1) do |wc_obj, index|
         #A way to accomplish this if only have Zip Code and GPS Features (and no additional ones)
         #zip_or_gps = wc_obj.current_conditions_means == "Zip Code" ? wc_obj.zip_code.colorize(:green) : "#{wc_obj.lat.colorize(:light_blue)}, #{wc_obj.long.colorize(:light_blue)}"
         #puts "#{index}. Weather by #{wc_obj.current_conditions_means}: #{zip_or_gps} (#{wc_obj.city_name.colorize(:green)}) fetched at #{wc_obj.when_fetched.colorize(:red)}"
         
         #extensible if further features added.
         case wc_obj.current_conditions_means
         when "Zip Code"
            puts "#{index}. Weather by Zip Code: #{wc_obj.zip_code.colorize(:green)} (#{wc_obj.city_name.colorize(:green)}) fetched at #{wc_obj.when_fetched.colorize(:red)}"
         when "GPS Coordinates"
            puts "#{index}. Weather by GPS: #{wc_obj.lat.colorize(:light_blue)}, #{wc_obj.long.colorize(:light_blue)} (#{wc_obj.city_name.colorize(:light_blue)}) fetched at #{wc_obj.when_fetched.colorize(:red)}"
         end
      end
   end
end