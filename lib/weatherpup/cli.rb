# CLI Controller
class WeatherPup::CLI
   def call
      #Clears the screen to make the interface look nicer / cleaner
      system "clear"
      
      #Welcome the user
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
      #Run the main menu
      self.main_menu
   end

   def main_menu
      #Initialize my trigger variable "input" for my until loop
      input = "no input yet"
      until input.downcase == 'exit'
         
         #Show the user their options and provide instructions on how to use.
         puts <<~MAINMENU

            #{"How would you like me to fetch the current weather conditions for you today?".colorize(:light_red)}
            
            #{"1. Fetch by Zip Code".colorize(:green)}
            #{"2. Fetch by GPS Coordinates (Latitude and Longitude)".colorize(:light_blue)}
            #{"3. Fetch previously fetched conditions".colorize(:cyan)}

            Please type #{"1".colorize(:green)}, #{"2".colorize(:light_blue)}, #{"3".colorize(:cyan)} or type #{"exit".colorize(:red)} to quit.
         MAINMENU
         
         #get input from the user
         input = gets.chomp.downcase

         #Check that input for a valid input.  If valid, then do what the user selected. Else, tell them the input is not valid and display the options again. 
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
      
      #Once the user types exit, clear the screen and then display the goodbye message
      system "clear"
      self.goodbye
   end

   #fetches the current conditions via zip code input from the user
   def fetch_by_zip
      #initialize my trigger variable zip_code_valid for my until loop
      zip_code_valid = nil
      
      #Clear my screen first to make things look nicer 
      system "clear"

      #Ask user for the zip code until we get a valid input. 
      puts "\nOk, Current Weather Conditions by Zip Code!".colorize(:green)
      until zip_code_valid
         puts "\nPlease enter in the 5 Digit Zip Code:".colorize(:green)
         zip_code = gets.chomp

         #Checking to see if the user wants out of this loop and back to the main menu
         if zip_code.downcase == "back"
            system "clear"
            break
         end

         #Otherwise, run #zip_code_valid to check to see if what the user put in was valid
         zip_code_valid = zip_code_valid?(zip_code)

         #If the zipcode input is valid, get and display the weather info. 
         if zip_code_valid
            #clear the screen
            system "clear" 
 
            #Do the actual work of getting the data from the API, processing it, and printing it to screen
            self.get_and_print_by_zip(zip_code)
            
            #Next I wait for the user to type in "back" to return to the main menu
            self.return_to_main_menu_prompt
            
            #Once the user types back, clear the screen and break out of this until loop
            system "clear"
            break
         else
            #If given junk data (invalid zip, jibberish input, etc) tell the user its not valid then tell them how to get back to the main menu if they want.
            puts <<~INVALID_ZIP
               \n#{"Invalid zip code detected!".colorize(:light_red)}
               
               (Type #{"back".colorize(:red)} to return to the main menu).
            INVALID_ZIP
         end
      end    
   end

   #Input validation method - Checks the VALID_US_ZIP_CODES constant to see if the zip code is real
   def zip_code_valid?(zip_to_check)
      VALID_US_ZIP_CODES.include?(zip_to_check)
   end   
   
   def get_and_print_by_zip(zip_code)
      #Instantiate a new instance of WeatherConditions class
      zip_weather_conditions = WeatherPup::WeatherConditions.new
 
      #set the zip_code attribute to the zip code entered by the user
      zip_weather_conditions.zip_code = zip_code

      #go fetch the raw api data
      api_raw_data = zip_weather_conditions.zip_api_fetch(zip_code)

      #process raw data into an attributes hash to use with mass assignment method #write_attributes
      api_processed_data_hash = zip_weather_conditions.zip_process_api_data_to_attribs_hash(api_raw_data)
      
      #This next line takes the zip_weather_conditions variable which is a WeatherConditions Object Instance, taps into it and writes all of the attributes that I collected & processed from the API, then it prints the information located in the object itself to the user.
      zip_weather_conditions.tap {|weather_conditions_obj| weather_conditions_obj.write_attributes(api_processed_data_hash)}.print_zip_conditions
   end


   #fetch the current conditions via zip code input from the user
   def fetch_by_gps
      #initialize my trigger variable valid_coordinates for my until loop
      valid_coordinates = nil

      #Clear my screen first to make things look nicer 
      system "clear"
      
      #Ask user for the latitude and longitude until we get a valid input. 
      puts "\nOk, Current Weather Conditions by GPS coordinates!".colorize(:light_blue)
      
      until valid_coordinates
         #Grab the Lat from the user
         puts "\nPlease enter in the ".colorize(:light_blue) + "latitude".colorize(:green).underline + " in decimal notation:".colorize(:light_blue)
         latitude = gets.chomp
         
         #Checking to see if the user wants out of this loop and back to the main menu before proceeding
         if latitude.downcase == "back"
            system "clear"
            break
         end

         #Grab the Longitude from the user
         puts "\nPlease enter in the ".colorize(:light_blue) + "longitude".colorize(:magenta).underline + " in decimal notation:".colorize(:light_blue)
         longitude = gets.chomp
         
         #Checking to see if the user wants out of this loop and back to the main menu
         if longitude.downcase == "back"
            system "clear"
            break
         end

         #Checking to see if the coordinates are valid using method #valid_coordinate_pair?
         valid_coordinates = self.valid_coordinate_pair?(latitude, longitude)
         
         # If the coordinates are valid, get and display the weather info.
         if valid_coordinates
            #Clear the screen to make it look nicer 
            system "clear" 

            #Do the actual work of getting the data from the API, processing it, and printing it to screen
            self.get_and_print_by_gps(latitude, longitude)
            
            #Next I wait for the user to type in "back" to return to the main menu 
            self.return_to_main_menu_prompt

            #Once the user types back, clear the screen and break out of this until loop
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

   def get_and_print_by_gps(latitude, longitude)
      #Instantiate a new instance of WeatherConditions class
      gps_weather_conditions = WeatherPup::WeatherConditions.new

      #go fetch the raw api data
      api_raw_data = gps_weather_conditions.gps_api_fetch(latitude, longitude)
      
      #process raw data into an attributes hash to use with mass assignment method #write_attributes
      api_processed_data_hash = gps_weather_conditions.gps_process_api_data_to_attribs_hash(api_raw_data)
      #This next line takes the gps_weather_conditions variable which is a WeatherConditions Object Instance, taps into it and writes all of the attributes that I collected, then it prints the information located in the object itself to the user.
      gps_weather_conditions.tap {|weather_conditions_obj| weather_conditions_obj.write_attributes(api_processed_data_hash)}.print_gps_conditions
   end

   def fetch_previous
      #Clear the screen to make it look nicer. 
      system "clear"

      #first check to see if there have been any previous checks -- if the array is blank, tell the user that there isn't anything to show.  Otherwise, print out a list of each WeatherConditions instance with details for the user pick from. 
      if WeatherPup::WeatherConditions.all == []
         system "clear"
         puts "\nThere are no previous fetches to display!".colorize(:cyan)
         self.return_to_main_menu_prompt
         system "clear"
      else
         #puts a blank line to give some headroom when displaying
         puts "\n"
         
         #ask the WeatherConditions class to print out a list of all its instances
         WeatherPup::WeatherConditions.list_all_previous

         #set my valid input range between 1 instance and however many instances of WeatherConditions there are in WeatherConditions @@all array.
         valid_input_range = 1..WeatherPup::WeatherConditions.all.length
         
         #Initialize my trigger to exit my until loop
         valid_input = nil
         
         #Until the user gives me a valid input, keep asking for a vaild input & give them the option to go back to the main menu.  If they do give me valid input, then go display that historic WeatherConditions object.
         until valid_input
            puts <<~USER_PROMPT
               \nPlease type in the #{"number".colorize(:cyan)} of the previous fetch you would like to view
               or type #{"back".colorize(:red)} to return to the main menu.
            USER_PROMPT
            
            #get the input fro mthe user
            user_selection = gets.chomp.downcase

            if user_selection == "back"
               system "clear"
               break
            end

            #convert my user input to an integer so that I can check to see if its in the valid range. 
            user_integer = user_selection.to_i
            valid_input = valid_input_range.member?(user_integer)

            #If it is in the valid range, go and print out the selected WeatherConditions objects info again.  Otherwise, keep asking for valid input and tell them how to go back. 
            if valid_input 
               selected_wc_obj = WeatherPup::WeatherConditions.all[user_integer - 1]
               type = selected_wc_obj.current_conditions_means

               case type 
               when "Zip Code"
                  system "clear"
                  selected_wc_obj.print_zip_conditions
                  self.return_to_main_menu_prompt
                  system "clear"
                  break
               when "GPS Coordinates"
                  system "clear"
                  selected_wc_obj.print_gps_conditions
                  self.return_to_main_menu_prompt
                  system "clear"
                  break
               end
            else
               puts "\n#{"Invalid selection.".colorize(:light_red)} Please try again or type #{"back".colorize(:red)} to return to the main menu."
            end
         end
      end
   end

   

   #This helper method displays instructions for the user to return to the main menu and then waits for the user to type in "back" before proceeding
   def return_to_main_menu_prompt
      return_to_main = ""
      until return_to_main.downcase == "back"
         puts "\nType #{"back".colorize(:red)} to return to the main menu."
         return_to_main = gets.chomp
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