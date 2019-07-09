class WeatherPup::CurrentConditions
   attr_accessor :reading_date_and_time, :current_conditions_means, :zip_code, :lat, :long, 
                 :temperature, :pressure, :humidity, :current_weather_description, :pressure, 
                 :wind_speed, :wind_direction_indicator, :wind_direction_indicator_string, :reading_date_and_time, :city_name
   #With this class I should be able to create a CurrentConditions instance by Zip code or GPS coordinates
   

   def self.new_by_zip
      zip_code = nil
      zip_code_valid = nil
      system "clear"
      puts "Ok, Current Weather Conditions by Zip Code!"
      until zip_code == 'back' || zip_code_valid
         puts "\nPlease enter in the 5 Digit Zip Code:"
         zip_code = gets.chomp

         zip_code_valid = self.zip_code_valid?(zip_code)

         if zip_code_valid
            system "clear" 
            zip_current_conditions = self.new
            api_hash = zip_current_conditions.zip_api_fetch(zip_code)
            #I should be able to refact these next two lines into one using chaining
            zip_current_conditions.write_attributes(api_hash)
            zip_current_conditions.print_zip_current_conditions
            continue = ""
            until continue.downcase == "back"
               puts "\nType 'back' to return to the main menu."
               continue = gets.chomp
            end
            system "clear"
            break
         elsif zip_code.downcase == "back"
            system "clear"
            break
         else
            puts <<~INVALID_ZIP
               \nInvalid Zip code detected!
               (Type 'back' to return to the main menu).
            INVALID_ZIP
         end
      end    
   end

   def self.zip_code_valid?(zip_to_check)
      VALID_US_ZIP_CODES.include?(zip_to_check)
   end

   def zip_api_fetch(zip_code, country_code = "us")
      #this will actually hit the OpenWeatherMap Api and then call a method that sets all the current_conditions attributes
      
      #I have defaulted the country code to US for now, but have built the GET request to be flexible to add multi-country postal codes later
      api_info = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},#{country_code}&APPID=#{APPID}&units=imperial")
      
      wind_direction_indicator_deg = api_info["wind"]["deg"].round
      wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg)

      #NOTE: REFACTOR Needed / Bug -- if you do another city I need to localize the time to that location's time zone - especially for sunrise and sunset

      {
         :current_weather_description => api_info["weather"][0]["main"],
         :current_conditions_means => "zip",
         :zip_code => zip_code,
         :temperature => api_info["main"]["temp"].round.to_s,
         :humidity => api_info["main"]["humidity"].to_s,
         :pressure => (api_info["main"]["pressure"] * 0.0295300).to_s[0..4],
         :wind_speed => api_info["wind"]["speed"].round.to_s,
         :wind_direction_indicator => wind_direction_indicator_deg,
         :wind_direction_indicator_string => wind_direction_indicator_string,
         :reading_date_and_time => Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z"),
         :city_name => api_info["name"]
      }
   end

   def self.new_by_gps
      latitude = nil
      longitude = nil
      valid_coordinates = nil
      system "clear"
      puts "Ok, Current Weather Conditions by GPS coordinates!"
      until latitude == 'back' || longitude == 'back' || valid_coordinates
         puts "\n\nPlease enter in the " + "latitude".colorize(:light_yellow).underline + " in decimal notation:"
         latitude = gets.chomp

         puts "\nPlease enter in the " + "longitude".colorize(:light_blue).underline + " in decimal notation:"
         longitude = gets.chomp

         valid_coordinates = self.valid_coordinate_pair?(latitude, longitude)

         if valid_coordinates
            system "clear" 
            gps_current_conditions = self.new
            api_raw_data = gps_current_conditions.gps_api_fetch(latitude, longitude)
            api_processed_data_hash = gps_current_conditions.gps_process_api_data_to_attribs_hash(api_raw_data)
            #This next line takes the gps_current_conditions variable which is a CurrentConditions Object Instance, taps into it and writes all of the attributes that I collected, then it prints the information located in the object itself.
            gps_current_conditions.tap {|current_conditions_obj| current_conditions_obj.write_attributes(api_processed_data_hash)}.print_gps_current_conditions
            
            continue = ""
            until continue.downcase == "back"
               puts "\nType 'back' to return to the main menu."
               continue = gets.chomp
            end
            system "clear"
            break
         elsif latitude.downcase == "back" || longitude.downcase == "back"
            system "clear"
            break
         else
            puts <<~INVALID_GPS
               \nInvalid Coordinates detected!
               (Type 'back' to return to the main menu).
            INVALID_GPS
         end
      end
   end

   def self.valid_coordinate_pair?(latitude, longitude)
      #If the lat & long user input contains alphabet characters, its not valid
      if latitude.match(/[a-zA-Z]/) || longitude.match(/[a-zA-Z]/) 
         false
      else
         #Checks to see if both the lat & long user input are within valid ranges
         VALID_LAT_RANGE.member?(latitude.to_f) && VALID_LONG_RANGE.member?(longitude.to_f)
      end
      #returns true if the lat and long coordinate pair is valid.
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
         wind_direction_indicator_deg = wind_direction_indicator_deg_rounded.to_s + "°"
      end
      #NOTE: REFACTOR Needed / Bug -- if you do another city I need to localize the time to that location's time zone - especially for sunrise and sunset

      attributes_hash_for_mass_assignment = {
         :current_weather_description => api_info["weather"][0]["main"],
         :current_conditions_means => "gps",
         :lat => api_info["coord"]["lat"].to_s,
         :long => api_info["coord"]["lon"].to_s,
         :temperature => api_info["main"]["temp"].round.to_s,
         :humidity => api_info["main"]["humidity"].to_s,
         :pressure => (api_info["main"]["pressure"] * 0.0295300).to_s[0..4],
         :wind_speed => api_info["wind"]["speed"].round.to_s,
         :wind_direction_indicator => wind_direction_indicator_deg,
         :wind_direction_indicator_string => wind_direction_indicator_string,
         :reading_date_and_time => Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z"),
         :city_name => api_info["name"]
      }
   end

   def write_attributes(processed_api_data_hash)
      #this will take whatever the API hash was and create attributes for the object that it's run on.
      processed_api_data_hash.map do |key, value|
         self.send("#{key}=", value)
      end
   end   

   def print_zip_current_conditions
      puts <<~CONDITIONS
         \nThe current weather conditions for #{self.city_name.colorize(:light_yellow).underline} (#{self.zip_code.colorize(:light_yellow)}):  
         
         #{self.temperature.colorize(:light_blue)}°F  
         #{self.humidity.colorize(:light_blue)}% Humidity
         #{self.current_weather_description.colorize(:light_blue)}

         Pressure: #{self.pressure.colorize(:light_blue)} in of Hg
         Wind Speed: #{self.wind_speed.colorize(:light_blue)} MPH 
         Wind Direction: #{self.wind_direction_indicator_string.colorize(:light_blue)} (#{self.wind_direction_indicator.to_s.colorize(:blue)}°)

         This data is based on the last weather station reading time of:
         #{self.reading_date_and_time.colorize(:yellow)}

         **Weather Data provided by OpenWeatherMap.org**
         **Zip Code data courtesy of AggData.com**
      CONDITIONS
   end

   def print_gps_current_conditions
      puts <<~CONDITIONS
         \nThe current weather conditions for #{self.lat.colorize(:light_yellow)}, #{self.long.colorize(:light_yellow)} (#{self.city_name.colorize(:light_yellow)}):  
         
         #{self.temperature.colorize(:light_blue)}°F  
         #{self.humidity.colorize(:light_blue)}% Humidity
         #{self.current_weather_description.colorize(:light_blue)}

         Pressure: #{self.pressure.colorize(:light_blue)} in of Hg
         Wind Speed: #{self.wind_speed.colorize(:light_blue)} MPH 
         Wind Direction: #{self.wind_direction_indicator_string.colorize(:light_blue)} (#{self.wind_direction_indicator.colorize(:light_blue)})

         This data is based on the last weather station reading time of:
         #{self.reading_date_and_time.colorize(:yellow)}

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