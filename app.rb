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

# Things that work

# hash = Hash.new
#  hash[:parent_directory] = nil
#  hash[:parent_directory] = {:file_name => "test.junk"}
#  hash[:parent_directory].merge!(nested_directory: nil) 

get '/files' do
	

	all_files_hash = Hash.new
	app_directory = File.dirname(__FILE__) + '/public/'
	my_directory = app_directory + 'sample_directory'
# we need to establish the parent directory to make sure that it is what we think it is. 
	if !(File.ftype(my_directory) == "directory")
		puts "Error! Given address is not a directory!"
	else
		all_files_hash[File.basename(my_directory)] = nil
		
		# it looks as though we've got an issue with the file structure not working correctly. Children directory aren't being added to the parent and what not.
		Find.find(my_directory) do |file|
			if File.ftype(file) == "directory"
				puts "we're in the directory loop"
				puts file.inspect
				if !(all_files_hash.has_key?(File.basename(file)))
					# we've only looked to see if the key exists, we will then want to add it to the hash after this. Once that is complete it's time to add files with the same directory. 
					puts File.expand_path("..", file).split('/')[-1]
					# we'll want to find the parent(s) of the directory, see if it exists or not, chances are it doesn't exist. 
					# I'll do a check on this later and not add it if it's redudndant, however I think Find.find prevents redundancies
					tmp_var_for_hash = File.basename(file)
					puts "we're in a checkloop for if hash has base key."
					# binding.pry
					# I don't think we really need this, honestly. 
				end
				puts all_files_hash
			else
				if !(get_all_keys(all_files_hash).include?(File.expand_path("..", file).split('/'[-1]).last))
					# we seem to end up in this loop a lot. I'm going to keep adding logic to it until it works well or someone helps me find a solution that makes sense 
					puts "pay attention!!"
					tmp_hash_for_merge = {File.expand_path("..", file).split('/'[-1]).last => nil}
					# binding.pry
					# all_files_hash[File.expand_path("..", file).split('/')[-2]].merge!tmp_hash_for_merge
					# 
					# The following block of code actually works. we'll wan't to apply it to the rest of our structure here and actually find the right parent to put the child with. 
					# 
					tmp_hold_my_file = file
					tmp_hold_my_file.slice! app_directory
					tmp_array = tmp_hold_my_file.split('/')
					tmp_array.each_with_index do |parent, index|
						if index == 0
					    	puts all_files_hash.has_key?(parent)
					    	# binding.pry
					  	else   
					  		# binding.pry
					    	case all_files_hash[tmp_array[index-1]].has_key?(parent)
					    	when false
					    			# puts all_files_hash[tmp_array[index-1]]
					    			all_files_hash[tmp_array[index-1]].merge!tmp_hash_for_merge
					    			break
				    		else
				    			puts all_files_hash.has_key?(parent)
				    		end
						end  
					end  


				elsif 	
					tmp_var_to_merge_into_hash = {
						File.basename(file) => {
							:file_name => File.basename(file),
							:file_size => File.size(file),
							:file_created_time => File.ctime(file),
						}
					}
					if all_files_hash[File.expand_path("..", file).split('/')[-1]] == nil
						all_files_hash[File.expand_path("..", file).split('/')[-1]] = tmp_var_to_merge_into_hash
						# binding.pry
					else 
						all_files_hash[File.expand_path("..", file).split('/')[-1]].merge!tmp_var_to_merge_into_hash
					end
				end
			end
		end
	end
	all_files_hash.to_json
end


# 			end

# 		puts File.basename(file)
# 		puts "Type is a " + File.ftype(file)
# 		puts File.dirname(file)
# 		print "Size is " 
# 			print (File.size(file).to_f / 2**20).round(2) 
# 			puts "mb"
# 		puts File.ctime(file)
# 		puts File.stat(file).inspect
# 		puts "-----------------------------------"

# 		all_files_hash.to_json
# 		end
# 	end

# end

not_found do  #<--- if somone access's a route that doesn't exist (error 404), then the following code will be executed

	redirect '/index' #<--- can redirect using "redirect" '/routename'

end

#NOTE: When you make changes to your app.rb file, you must stop and start your sinatra server.



