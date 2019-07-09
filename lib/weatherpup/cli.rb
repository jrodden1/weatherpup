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
      until input == 'exit'
         puts <<~MAINMENU

            How would you like me to fetch the current weather conditions for you today?
            
            1. Fetch by Zip Code
            2. Fetch by GPS Coordinates
            (Latitude and Longitude)
            
            Please select 1 or 2 to continue or type ‘exit’ to quit."
         MAINMENU
         input = gets.chomp

         case input
         
         when "1"
            WeatherPup::CurrentConditions.new_by_zip
         when "2"
            WeatherPup::CurrentConditions.new_by_gps
         else
            puts "\nSorry, that isn’t a valid input."
         end
      end
      system "clear"
      self.goodbye
   end

   def goodbye
      system "clear"
      puts <<~GOODBYE
      ▀▀█▀▀ █░░█ █▀▀█ █▀▀▄ █░█ █▀▀ 　 █▀▀ █▀▀█ █▀▀█ 　 █▀▀█ █░░ █▀▀█ █░░█ ░▀░ █▀▀▄ █▀▀▀ 
      ░▒█░░ █▀▀█ █▄▄█ █░░█ █▀▄ ▀▀█ 　 █▀▀ █░░█ █▄▄▀ 　 █░░█ █░░ █▄▄█ █▄▄█ ▀█▀ █░░█ █░▀█ 
      ░▒█░░ ▀░░▀ ▀░░▀ ▀░░▀ ▀░▀ ▀▀▀ 　 ▀░░ ▀▀▀▀ ▀░▀▀ 　 █▀▀▀ ▀▀▀ ▀░░▀ ▄▄▄█ ▀▀▀ ▀░░▀ ▀▀▀▀ 
      
       　 　 　 　█▀▀ █▀▀ ▀▀█▀▀ █▀▀ █░░█ 　 █░░░█ ░▀░ ▀▀█▀▀ █░░█ 　 █▀▄▀█ █▀▀ █           
       　 　 　 　█▀▀ █▀▀ ░░█░░ █░░ █▀▀█ 　 █▄█▄█ ▀█▀ ░░█░░ █▀▀█ 　 █░▀░█ █▀▀ ▀ 
       　 　 　 　▀░░ ▀▀▀ ░░▀░░ ▀▀▀ ▀░░▀ 　 ░▀░▀░ ▀▀▀ ░░▀░░ ▀░░▀ 　 ▀░░░▀ ▀▀▀ ▄ 
      
                             Thank you for using WeatherPup!
                        Cool Welcome and Goodbye Text by fsymbols.com   
                               Created by Jeremiah Rodden
                              
      GOODBYE
   end

end