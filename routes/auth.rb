class MyApp < Sinatra::Application

# AUTH ROUTES

	get '/auth/login' do
		slim :login
	end

	post '/auth/login' do
		env['warden'].authenticate!
		flash.success = "Successfully logged in"

		if session[:return_to].nil?
			# bring admins to the admin page
			if admin? env['warden'].user
				redirect '/'
			end
			redirect '/'
		else
			redirect session[:return_to]
		end
	end

	get '/auth/logout' do
		env['warden'].raw_session.inspect
		env['warden'].logout
		flash.success = "Successfully logged out."
		redirect '/'
	end

	post '/auth/unauthenticated' do
		session[:return_to] = env['warden.options'][:attempted_path]
		puts env['warden.options'][:attempted_path]
		flash.error = env['warden'].message || "You must log in"
		redirect '/auth/login'
	end
	
end
