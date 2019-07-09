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