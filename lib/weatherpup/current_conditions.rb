class WeatherPup::CurrentConditions
   attr_accessor :reading_date_and_time, :current_conditions_means, :zip_code, :lat, :long, :temperature, :pressure, :humidity, :current_weather_description, :pressure, :wind_speed, :wind_direction_indicator, :wind_direction_indicator_string, :reading_date_and_time, :time_zone_in_text, :localized_sunrise_time, :localized_sunset_time, :city_name
   #With this class I should be able to create a CurrentConditions instance by Zip code or GPS coordinates
   

   def self.new_by_zip
      zip_code = nil
      zip_code_valid = nil
      system "clear"
      puts "Ok, Current Weather Conditions by Zip Code!"
      until zip_code == 'back' || zip_code_valid == 'true'
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

   def self.new_by_gps(latitude, longitude)
      gps_current_conditions = self.new
      gps_current_conditions.zip_api_fetch(latitude, longitude)
   end

   def zip_api_fetch(zip_code, country_code = "us")
      #this will actually hit the OpenWeatherMap Api and then call a method that sets all the current_conditions attributes
      #Stubbed:
      #{
      #   :current_conditions_means => 'zip',
      #   :zip_code => zip_code,
      #   :reading_date_and_time => "Tuesday, July 1, 2019 1:00PM",
      #   :temperature => "85",
      #   :humidity => "50",
      #   :current_weather_description => "Clear",
      #   :pressure => "29.92",
      #   :wind_speed => "7",
      #   :wind_direction_indicator => "NW",
      #   :localized_date_and_time => "Tuesday, July 1, 2019 2:17PM",
      #   :time_zone_in_text => "-2", ###WONT NEED THIS 
      #   :localized_sunrise_time => "6:30AM",
      #   :localized_sunset_time => "8:46PM",
      #}
      #base_uri = api.openweathermap.org/data/2.5/weather/
      #self.class.get("zip=#{zip_code},us&APPID=#{APPID})
      #I have defaulted the country code to US for now, but have built the GET request to be flexible to add multi-country postal codes later
      api_info = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},#{country_code}&APPID=#{APPID}&units=imperial")
      #current_weather_conditions = api_info["weather"][0]["main"]
      #temperature = api_info["main"]["temp"]
      #pressure in inches of mercury = (api_info["main"]["pressure"]* 0.0295300).round(2)
      #humidity % = api_info["main"]["humidity"]
      #visibility = (api_info["visibility"] * 0.00062).round.to_s
      #Wind speed = api_info["wind"]["speed"]
      #simple wind direction = api_info["wind"]["deg"].round  # Will need to write a method that checks if this number is betwen ranges for N, NE, E, SE, S, SW, W, NW
      # see method below for wind Direction converstion to text
      #Date and Time of when the reading was taken last = Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z")
      #Localized Sunrise Time = Time.at(api_info["sys"]["sunrise"]).to_datetime.strftime("%I:%M%P")
      #Localized Sunset Time = Time.at(api_info["sys"]["sunset"]).to_datetime.strftime("%I:%M%P")
      
      wind_direction_indicator_deg = api_info["wind"]["deg"].round
      wind_direction_indicator_string = wind_direction_indicator_to_text(wind_direction_indicator_deg)

      {
         :current_weather_description => api_info["weather"][0]["main"],
         :current_conditions_means => "zip",
         :zip_code => zip_code,
         :temperature => api_info["main"]["temp"].round,
         :humidity => api_info["main"]["humidity"],
         :pressure => (api_info["main"]["pressure"] * 0.0295300).to_s[0..4],
         :wind_speed => api_info["wind"]["speed"].round,
         :wind_direction_indicator => wind_direction_indicator_deg,
         :wind_direction_indicator_string => wind_direction_indicator_string,
         :reading_date_and_time => Time.at(api_info["dt"]).to_datetime.strftime("%a, %b %d, %Y at %I:%M%P UTC%:::z"),
         :localized_sunrise_time => Time.at(api_info["sys"]["sunrise"]).to_datetime.strftime("%I:%M%P"),
         :localized_sunset_time => Time.at(api_info["sys"]["sunset"]).to_datetime.strftime("%I:%M%P"),
         :city_name => api_info["name"]
      }
   end
   
   def self.zip_code_valid?(zip_to_check)
      VALID_US_ZIP_CODES.include?(zip_to_check)
   end

   def gps_api_fetch(latitude, longitude)
      #this will actually hit the OpenWeatherMap Api and then return all the information 
   end

   def write_attributes(api_hash)
      #this will take whatever the API hash was and create attributes for the object that it's run on.
      api_hash.map do |key, value|
         self.send("#{key}=", value)
      end
   end   

   def print_zip_current_conditions
      puts <<~CONDITIONS
         \nThe current weather conditions for #{self.city_name} (#{self.zip_code}):  
         
         #{self.temperature}°F  
         #{self.humidity}% Humidity
         #{self.current_weather_description}

         Pressure: #{self.pressure} in of Hg
         Wind Speed: #{self.wind_speed} MPH 
         Wind Direction: #{self.wind_direction_indicator_string} (#{self.wind_direction_indicator}°)

         Sunrise: #{self.localized_sunrise_time} 
         Sunset: #{self.localized_sunset_time} 

         This data is based on the last weather station reading time of:
         #{self.reading_date_and_time}

         **Weather Data provided by OpenWeatherMap.org**
         **Zip Code data courtesy of AggData.com**
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