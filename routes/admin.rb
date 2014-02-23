


class MyApp < Sinatra::Application
	
	# initial admin page
	get '/admin/?' do
		env['warden'].authenticate!
		@current_user = env['warden'].user
		unless admin? @current_user
			flash.error = "You do not have permission to view that page."
			redirect '/'
		end

		slim :admin, :locals => { :u => @current_user }
	end

	# user list
	get '/admin/users/?' do
		env['warden'].authenticate!
		@current_user = env['warden'].user
		
		unless admin? @current_user
			flash.error = "You do not have permission to view that page"
			redirect '/'
		end
		slim :list, :locals =>{ :us => User.all(:user_group => "user") }

	end
end