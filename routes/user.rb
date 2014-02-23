class MyApp < Sinatra::Application
	

	# ALL USER ROUTES

	#form for creating new user
	get '/users/new' do
		slim :signup_form, :locals => { :u => User.new, :action => '/users/create'}	
	end
	
	# Creates a new user
	post '/users/create' do

		u = User.new
		u.attributes = params
		u.save
	
		redirect "/users/#{u.id}"
	end
	
	# Form to edit a user
	get '/users/:id/edit' do |id|
		env['warden'].authenticate!
		@current_user = env['warden'].user
		u = User.get(id)
		
		unless id == @current_user.id.to_s || admin?(@current_user)
			flash.error = "You do not have permission to view that page"
			redirect '/'
		end
		slim :edit_user, :locals => { :u => u, :action => "/users/#{u.id}/update" }		
	end
	
	# Edit a user
	post '/users/:id/update' do |id|
		env['warden'].authenticate!

		u = User.get(id)
		u.update({:username =>params[:username], :email => params[:email], :password => params[:password]})
	
		redirect "/users/#{id}"
	end
	
	# Delete a user
	post '/users/:id/destroy' do |id|
		env['warden'].authenticate!

		u = User.get(id)
		u.destroy
		flash.success = "User successfully destroyed."
		redirect "/admin/users/"
	end
	
	# View a User
	get '/users/:id/?' do |id|
		env['warden'].authenticate!
		@current_user = env['warden'].user
		u = User.get(id)
		
		unless id == @current_user.id.to_s || admin?(@current_user)
			flash.error = "You do not have permission to view that page"
			redirect '/'
		end
		
		slim :show, :locals => { :u => u }
	end

	# user sale items

	get '/user/items/?' do 
		env['warden'].authenticate!
		@current_user = env['warden'].user
		saleItems = SaleItem.all(:userid => @current_user.id )
		slim :itemList, :locals => { :items => saleItems }
	end

end