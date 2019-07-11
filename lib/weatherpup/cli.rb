# CLI Controller
class WeatherPup::CLI
   def call
      system "clear"
      #puts "Welcome to WeatherPup!"  #simple intro
      puts <<~WELCOME
      　　　　　 ▒█░░▒█ █▀▀ █░░ █▀▀ █▀▀█ █▀▄▀█ █▀▀ 　 ▀▀█▀▀ █▀▀█    
      　　　　　 ▒█▒█▒█ █▀▀ █░░ █░░ █░░█ █░▀░█ █▀▀ 　 ░▒█░░ █░░█ 
      　　　　　 ▒█▄▀▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀▀ ▀░░░▀ ▀▀▀ 　 ░▒█░░ ▀▀▀▀
      
           　 ▒█░░▒█ █▀▀ █▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀█ ▒█▀▀█ █░░█ █▀▀█ █      
           　 ▒█▒█▒█ █▀▀ █▄▄█ ░░█░░ █▀▀█ █▀▀ █▄▄▀ ▒█▄▄█ █░░█ █░░█ ▀      
           　 ▒█▄▀▄█ ▀▀▀ ▀░░▀ ░░▀░░ ▀░░▀ ▀▀▀ ▀░▀▀ ▒█░░░ ░▀▀▀ █▀▀▀ ▄  
      　
           　                ░░░░░░░░░░░░░░░░▄██
           　                ░░░░▄████▄▄▄▄▄▄███████
           　                ░░▄█▀████████████▀
           　                ░▄▀░██▀██▀▀▀▀▀██▀▀▄
           　                ░░░░█▄░▀█▄░░░░▀█▄▀▀
      WELCOME
      main_menu
   end

   def main_menu
      input = "no input"
      until input.downcase == 'exit'
         puts <<~MAINMENU

            #{"How would you like me to fetch the current weather conditions for you today?".colorize(:light_red)}
            
            #{"1. Fetch by Zip Code".colorize(:green)}
            #{"2. Fetch by GPS Coordinates (Latitude and Longitude)".colorize(:light_blue)}
            #{"3. Fetch previously fetched conditions".colorize(:cyan)}

            Please type #{"1".colorize(:green)}, #{"2".colorize(:light_blue)}, #{"3".colorize(:cyan)} or type #{"exit".colorize(:red)} to quit.
         MAINMENU
         input = gets.chomp.downcase

         case input
         when "1"
            self.fetch_by_zip
         when "2"
            self.fetch_by_gps
         when "3"
            self.fetch_previous
         when "exit"
            break
         else
            puts "\nSorry, that isn’t a valid input.".colorize(:red)
         end
      end
      system "clear"
      self.goodbye
   end

   #fetch the current conditions via zip code input from the user
   def fetch_by_zip
      #may not need zip_code variable declaration here) 
      #zip_code = nil
      zip_code_valid = nil
      
      #Clear my screen first to make things look nicer 
      system "clear"

      #Ask user for the zip code
      puts "\nOk, Current Weather Conditions by Zip Code!".colorize(:green)
      until zip_code_valid
         puts "\nPlease enter in the 5 Digit Zip Code:".colorize(:green)
         zip_code = gets.chomp

         #Checking to see if the user wants out of this loop and back to the main menu
         if zip_code.downcase == "back"
            system "clear"
            break
         end

         #Otherwise, check to see if what the user put in was valid
         zip_code_valid = zip_code_valid?(zip_code)

         #If the zipcode input is valid, clear the screen, instantiate a new instance of WeatherConditions class, go fetch the raw api data, process it into an attributes hash to mass assign, mass assign the attributes of the WeatherConditions intance using #write_attributes, then print the current conditions to screen gps
         if zip_code_valid
            system "clear" 
            zip_weather_conditions = WeatherPup::WeatherConditions.new
            zip_weather_conditions.zip_code = zip_code
            api_raw_data = zip_weather_conditions.zip_api_fetch(zip_code)
            api_processed_data_hash = zip_weather_conditions.zip_process_api_data_to_attribs_hash(api_raw_data)
            
            #This next line takes the zip_weather_conditions variable which is a WeatherConditions Object Instance, taps into it and writes all of the attributes that I collected, then it prints the information located in the object itself.
            zip_weather_conditions.tap {|weather_conditions_obj| weather_conditions_obj.write_attributes(api_processed_data_hash)}.print_zip_conditions
            
            #Next I wait for the user to type in "back" to return to the main menu
            return_to_main_menu_prompt
            system "clear"
            break
         else
            puts <<~INVALID_ZIP
               \n#{"Invalid zip code detected!".colorize(:light_red)}
               
               (Type #{"back".colorize(:red)} to return to the main menu).
            INVALID_ZIP
         end
      end    
   end
   
   def return_to_main_menu_prompt
      return_to_main = ""
      until return_to_main.downcase == "back"
         puts "\nType #{"back".colorize(:red)} to return to the main menu."
         return_to_main = gets.chomp
      end
   end

   
   def zip_code_valid?(zip_to_check)
      #checks the VALID_US_ZIP_CODES constant to see if the zip code is real
      VALID_US_ZIP_CODES.include?(zip_to_check)
   end

   #fetch the current conditions via zip code input from the user
   def fetch_by_gps
      latitude = nil
      longitude = nil
      valid_coordinates = nil
      system "clear"
      puts "\nOk, Current Weather Conditions by GPS coordinates!".colorize(:light_blue)
      
      until valid_coordinates
         #Grab the Lat from the user
         puts "\nPlease enter in the ".colorize(:light_blue) + "latitude".colorize(:green).underline + " in decimal notation:".colorize(:light_blue)
         latitude = gets.chomp
         
         #Checking to see if the user wants out of this loop and back to the main menu
         if latitude.downcase == "back"
            system "clear"
            break
         end

         #Grab the Long from the user
         puts "\nPlease enter in the ".colorize(:light_blue) + "longitude".colorize(:magenta).underline + " in decimal notation:".colorize(:light_blue)
         longitude = gets.chomp
         #Checking to see if the user wants out of this loop and back to the main menu
         if longitude.downcase == "back"
            system "clear"
            break
         end

         #Checking to see if the coordinates are valid using class method #valid_coordinate_pair?
         valid_coordinates = self.valid_coordinate_pair?(latitude, longitude)
         
         # If the coordinates are valid, then then instantiate a new instance of WeatherConditions Object, hit the weather conditions api, write the object's attributes using mass assignment (#write_attributes), then #print_gps_conditions to screen
         if valid_coordinates
            system "clear" 
            gps_weather_conditions = WeatherPup::WeatherConditions.new
            api_raw_data = gps_weather_conditions.gps_api_fetch(latitude, longitude)
            api_processed_data_hash = gps_weather_conditions.gps_process_api_data_to_attribs_hash(api_raw_data)
            #This next line takes the gps_weather_conditions variable which is a WeatherConditions Object Instance, taps into it and writes all of the attributes that I collected, then it prints the information located in the object itself.
            gps_weather_conditions.tap {|weather_conditions_obj| weather_conditions_obj.write_attributes(api_processed_data_hash)}.print_gps_conditions
            
            return_to_main_menu_prompt
            system "clear"
            break
         else
            puts <<~INVALID_GPS
               \n#{"Invalid coordinates detected!".colorize(:light_red)} 
               
               (Type #{"back".colorize(:red)} to return to the main menu).
            INVALID_GPS
         end
      end
   end

   #Do some basic checks to make sure that the coordinates are legit
   def valid_coordinate_pair?(latitude, longitude)
      #If the lat & long user input contains alphabet characters, it's not valid
      if latitude.match(/[a-zA-Z]/) || longitude.match(/[a-zA-Z]/) 
         false
      else
         #Checks to see if both the lat & long user input are within valid ranges
         VALID_LAT_RANGE.member?(latitude.to_f) && VALID_LONG_RANGE.member?(longitude.to_f)
      end
      #returns true if the lat and long coordinate pair is valid.
   end

   def fetch_previous
      system "clear"
      if WeatherPup::WeatherConditions.all == []
         system "clear"
         puts "\nThere are no previous fetches to display!".colorize(:cyan)
         return_to_main_menu_prompt
         system "clear"
      else
         #puts a blank line to give some headroom when displaying
         puts "\n"
         #Can possibly abstract this next section into a method called "list_all_previous" to make the #fetch_previous method a bit less cumbersome to read
         WeatherPup::WeatherConditions.all.each.with_index(1) do |wc_obj, index|
            case wc_obj.current_conditions_means
            when "Zip Code"
               puts "#{index}. Weather by Zip Code: #{wc_obj.zip_code.colorize(:green)} (#{wc_obj.city_name.colorize(:green)}) fetched at #{wc_obj.when_fetched.colorize(:red)}"
            when "GPS Coordinates"
               puts "#{index}. Weather by GPS: #{wc_obj.lat.colorize(:light_blue)}, #{wc_obj.long.colorize(:light_blue)} (#{wc_obj.city_name.colorize(:light_blue)}) fetched at #{wc_obj.when_fetched.colorize(:red)}"
            end
         end 

         valid_input_range = 1..WeatherPup::WeatherConditions.all.length
         valid_input = nil
         
         until valid_input
            puts <<~USER_PROMPT
               \nPlease type in the #{"number".colorize(:cyan)} of the previous fetch you would like to view
               or type #{"back".colorize(:red)} to return to the main menu.
            USER_PROMPT
            user_selection = gets.chomp

            if user_selection.downcase == "back"
               system "clear"
               break
            end

            user_integer = user_selection.to_i
            valid_input = valid_input_range.member?(user_integer)

            if valid_input 
               selected_wc_obj = WeatherPup::WeatherConditions.all[user_integer - 1]
               type = selected_wc_obj.current_conditions_means

               case type 
               when "Zip Code"
                  system "clear"
                  selected_wc_obj.print_zip_conditions
                  return_to_main_menu_prompt
                  system "clear"
                  break
               when "GPS Coordinates"
                  system "clear"
                  selected_wc_obj.print_gps_conditions
                  return_to_main_menu_prompt
                  system "clear"
                  break
               end
            else
               puts "\n#{"Invalid selection.".colorize(:light_red)} Please try again or type #{"back".colorize(:red)} to return to the main menu."
            end
         end
      end
   end
   
   #Says thank you and goodbye to user. 
   def goodbye
      system "clear"
      puts <<~GOODBYE
           　  　 　    ▀▀█▀▀ █░░█ █▀▀█ █▀▀▄ █░█ █▀▀ 　 █▀▀ █▀▀█ █▀▀█ 
           　  　 　    ░▒█░░ █▀▀█ █▄▄█ █░░█ █▀▄ ▀▀█ 　 █▀▀ █░░█ █▄▄▀ 
           　  　 　    ░▒█░░ ▀░░▀ ▀░░▀ ▀░░▀ ▀░▀ ▀▀▀ 　 ▀░░ ▀▀▀▀ ▀░▀▀       
           
           　　　█▀▀█ █░░ █▀▀█ █░░█ ░▀░ █▀▀▄ █▀▀▀ 　 █▀▀ █▀▀ ▀▀█▀▀ █▀▀ █░░█ 
           　　　█░░█ █░░ █▄▄█ █▄▄█ ▀█▀ █░░█ █░▀█ 　 █▀▀ █▀▀ ░░█░░ █░░ █▀▀█ 
           　　　█▀▀▀ ▀▀▀ ▀░░▀ ▄▄▄█ ▀▀▀ ▀░░▀ ▀▀▀▀ 　 ▀░░ ▀▀▀ ░░▀░░ ▀▀▀ ▀░░▀ 

           　  　 　 　 　   █░░░█ ░▀░ ▀▀█▀▀ █░░█ 　 █▀▄▀█ █▀▀ █            
           　  　 　 　 　   █▄█▄█ ▀█▀ ░░█░░ █▀▀█ 　 █░▀░█ █▀▀ ▀ 
           　  　 　 　 　   ░▀░▀░ ▀▀▀ ░░▀░░ ▀░░▀ 　 ▀░░░▀ ▀▀▀ ▄ 

                               Thank you for using WeatherPup!
                        Cool Welcome and Goodbye Text by fsymbols.com   
                                 Created by Jeremiah Rodden
                                            2019           
                              
      GOODBYE
   end
end