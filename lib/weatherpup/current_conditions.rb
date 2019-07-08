class WeatherPup::CurrentConditions
   attr_accessor :reading_date_and_time, :current_conditions_means, :zip_code, :lat, :long, :temperature, :humidity, :current_weather_description, :pressure, :wind_speed, :wind_direction_indicator, :localized_date_and_time, :time_zone_in_text, :localized_sunrise_time, :localized_sunset_time
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
            zip_current_conditions.write_attributes(api_hash)
            zip_current_conditions.print_zip_current_conditions
            continue = ""
            until continue.downcase == "back"
               puts "\nType 'back' to return to the main menu."
               continue = gets.chomp
            end
            system "clear"
            break
         else
            puts <<~INVALID_ZIP
               \nInvalid Zip code detected!
               (Type 'back' to return to the main menu)."
            INVALID_ZIP
         end
      end    
   end

   def self.new_by_gps(latitude, longitude)
      gps_current_conditions = self.new
      gps_current_conditions.zip_api_fetch(latitude, longitude)
   end

   def zip_api_fetch(zip_code)
      #this will actually hit the OpenWeatherMap Api and then call a method that sets all the current_conditions attributes
      #Stubbed:
      {
         :current_conditions_means => 'zip',
         :zip_code => zip_code,
         :reading_date_and_time => "Tuesday, July 1, 2019 1:00PM",
         :temperature => "85",
         :humidity => "50",
         :current_weather_description => "Clear",
         :pressure => "29.92",
         :wind_speed => "7",
         :wind_direction_indicator => "NW",
         :localized_date_and_time => "Tuesday, July 1, 2019 2:17PM",
         :time_zone_in_text => "-2",
         :localized_sunrise_time => "6:30AM",
         :localized_sunset_time => "8:46PM",
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
         \nAs of #{self.reading_date_and_time}, the weather for #{self.zip_code} is:
         #{self.temperature}°F  #{self.humidity}% Humidity
         #{self.current_weather_description}

         Pressure: {pressure}
         Wind Speed: #{self.wind_speed} #{self.wind_direction_indicator}
         Current time at location: #{self.localized_date_and_time} UTC#{self.time_zone_in_text}

         Sunrise: #{self.localized_sunrise_time} 
         Sunset: #{self.localized_sunset_time} 

         **Weather Data provided by OpenWeatherMap.org**
         **Zip Code data courtesy of AggData.com**
      CONDITIONS
   end
      

      #may need to do a while or unless loop here so it keeps waiting for a valid yes or no input
      ## I think I may just trash this functionality to reduce complexity
      #another_zip = nil
      #another_gps = nil
      #case CurrentConditions_means

      #when "zip"
      #   puts <<~ANOTHER_ZIP
      #   Would you like to look up the current weather at another zip code?
      #   Please type ‘yes’ or ’no’. 
      #   ANOTHER_ZIP
      #   another_zip = gets.chomp
      #when "gps"
      #   puts <<~ANOTHER_GPS
      #   Would you like to look up the current weather at another GPS location?
      #   Please type ‘yes’ or ’no’. 
      #   ANOTHER_GPS
      #   another_gps = gets.chomp
      #end
      
  
end