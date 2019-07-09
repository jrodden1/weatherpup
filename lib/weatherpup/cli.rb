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

            #{"How would you like me to fetch the current weather conditions for you today?".colorize(:magenta)}
            
            #{"1. Fetch by Zip Code".colorize(:light_yellow)}
            #{"2. Fetch by GPS Coordinates".colorize(:light_blue)}
            #{"(Latitude and Longitude)".colorize(:light_blue)}
            
            Please type #{"1".colorize(:light_yellow)}, #{"2".colorize(:light_blue)}, or type #{"exit".colorize(:red)} to quit.
         MAINMENU
         input = gets.chomp

         case input
         
         when "1"
            fetch_by_zip
         when "2"
            fetch_by_gps
         else
            puts "\nSorry, that isn’t a valid input."
         end
      end
      system "clear"
      self.goodbye
   end

   def fetch_by_zip
      
      
      
      WeatherPup::CurrentConditions.new_by_zip


   end

   def fetch_by_gps
      latitude = nil
      longitude = nil
      valid_coordinates = nil
      system "clear"
      puts "Ok, Current Weather Conditions by GPS coordinates!"
      
      until valid_coordinates
         #Grab the Lat from the user
         puts "\nPlease enter in the " + "latitude".colorize(:light_yellow).underline + " in decimal notation:"
         latitude = gets.chomp
         
         #Checking to see if the user wants out of this loop and back to the main menu
         if latitude.downcase == "back"
            system "clear"
            break
         end

         #Grab the Long from the user
         puts "\nPlease enter in the " + "longitude".colorize(:light_blue).underline + " in decimal notation:"
         longitude = gets.chomp
         #Checking to see if the user wants out of this loop and back to the main menu
         if longitude.downcase == "back"
            system "clear"
            break
         end

         #Checking to see if the coordinates are valid using class method #valid_coordinate_pair?
         valid_coordinates = self.valid_coordinate_pair?(latitude, longitude)
         
         # If the coordinates are valid, then then instantiate a new instance of Current Conditions Object, hit the weather conditions api, write the object's attributes using mass assignment (#write_attributes), then #print_gps_current_conditions to screen
         if valid_coordinates
            system "clear" 
            gps_current_conditions = WeatherPup::CurrentConditions.new
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
         else
            puts <<~INVALID_GPS
               \nInvalid Coordinates detected!
               (Type 'back' to return to the main menu).
            INVALID_GPS
         end
      end
   end

   def valid_coordinate_pair?(latitude, longitude)
      #If the lat & long user input contains alphabet characters, its not valid
      if latitude.match(/[a-zA-Z]/) || longitude.match(/[a-zA-Z]/) 
         false
      else
         #Checks to see if both the lat & long user input are within valid ranges
         VALID_LAT_RANGE.member?(latitude.to_f) && VALID_LONG_RANGE.member?(longitude.to_f)
      end
      #returns true if the lat and long coordinate pair is valid.
   end

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