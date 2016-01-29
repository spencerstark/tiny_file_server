require 'sinatra'
require 'shotgun'
require 'socket'
require 'json'
require 'find'
require 'pry'

#############################################################
# This app is loaded by cd'ing to the directory in terminal,
# and then typing in "ruby app.rb". That terminal window will show the webserver status and who is accessing the routes. 
# By default, sinatra is loaded on port 4567. If you want to run it on port 80 then remove the # sign in front of "set :port, 80"
# If you want to bind it to spencer.macpractice.lan, then remove the # sign from "set :bind, spencer.macpractice.lan"
#############################################################
# set :port, 80
# set :bind, ""
#############################################################


get '/index' do 
  puts request.ip.to_s
  erb :index
end

get '/test_json' do
  hash = { :directory => 
        { :first_file => {:name => "thing", :size => "size mb" },
         :second_file => {:name => "thing", :size => "size mb" },
         :nested_directory => 
          {:test_file => {:name => "thaing", :size => "sdize mb" }, },
        },
      }

  hash.to_json
end 

get '/files' do
  all_files_hash = Hash.new
  app_directory = File.dirname(__FILE__) + '/public/'
  my_directory = app_directory + 'sample_directory'

  def store_children_for_directory(directory_name, hash)
    hash[directory_name] = {files: []}
    Dir.glob(directory_name+'/*') do |file|
      if File.file? file 
        hash[directory_name][:files] << file 
      else
        hash[directory_name][file] = {files: []}
        #Recurse through the child_directories
        store_children_for_directory(file, hash[directory_name])
      end  
    end
  end

  store_children_for_directory(my_directory, all_files_hash)
  all_files_hash.to_json
end

not_found do  
  redirect '/index' 
end




