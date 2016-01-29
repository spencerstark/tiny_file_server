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

# set :port, 80
# set :bind, ""


#############################################################

# Borrowed this little diddy from SO. http://stackoverflow.com/questions/20235206/ruby-get-all-keys-in-a-hash-including-sub-keys
def get_all_keys(hash)
  hash.map do |k, v|
    Hash === v ? [k, get_all_keys(v)] : [k]
  end.flatten
end
#############################################################

get '/index' do  #<--- This is a route. A route makes it easy to redirect users to content based on what url they pick. You can also have variables in routes.
	puts request.ip.to_s
	erb :index   #<--- This is a block of code in the route. In this case we are sending the person who accessed the URL www.somepage.com/index to the index.erb file. 

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
# we need to establish the parent directory to make sure that it is what we think it is. 
	if !(File.ftype(my_directory) == "directory")
		puts "Error! Given address is not a directory!"
	else		
		tmp_var_to_merge_into_hash = {
			File.basename(my_directory) => {
				:file_name => File.basename(my_directory),
				:file_size => File.size(my_directory),
				:file_created_time => File.ctime(my_directory),
			}
		}
		all_files_hash["all files hash"] = tmp_var_to_merge_into_hash

		# it looks as though we've got an issue with the file structure not working correctly. Children directory aren't being added to the parent and what not.
		Find.find(my_directory) do |file|	
			tmp_hash_for_merge = {File.expand_path("..", file).split('/'[-1]).last => nil}
			# The following block of code actually works. we'll wan't to apply it to the rest of our structure here and actually find the right parent to put the child with. 
			# We need to find out what we're in, then act accordingly. 
			tmp_var_to_merge_into_hash = {
					File.basename(file) => {
						:file_name => File.basename(file),
						:file_size => File.size(file),
						:file_created_time => File.ctime(file),
					}
				}
			tmp_hold_my_file = file
			tmp_hold_my_file.slice! app_directory
			tmp_array = tmp_hold_my_file.split('/')
			tmp_array.each_with_index do |parent, index|
				if index == 0
			    	puts all_files_hash.has_key?(parent)
			    	# We're here on the very first directory, which should be the same as my_directory
			  	elsif all_files_hash["all files hash"][tmp_array[index-1]] == nil
			  		# binding.pry
			  		tmp_im_out_of_patience = tmp_array[index-1]
			  		all_files_hash["all files hash"][tmp_im_out_of_patience].merge!tmp_var_to_merge_into_hash
			  	else  			    	
			  		# This is breaking because we can't test for keys on an empty array. 
			    	case all_files_hash["all files hash"][tmp_array[index-1]].has_key?(parent)
			    	when false
			    			puts all_files_hash["all files hash"][tmp_array[index-1]]
			    			binding.pry
			    			all_files_hash["all files hash"][tmp_array[index-1]].merge!tmp_var_to_merge_into_hash
							break
		    		else
		    			puts all_files_hash.has_key?(parent)
		    		end
				end  
			end  
		end
	end
	all_files_hash.to_json
end

not_found do  #<--- if somone access's a route that doesn't exist (error 404), then the following code will be executed

	redirect '/index' #<--- can redirect using "redirect" '/routename'

end

#NOTE: When you make changes to your app.rb file, you must stop and start your sinatra server.



