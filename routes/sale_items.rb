require 'net/http'

class MyApp < Sinatra::Application

	post '/saleitem/new' do
		env['warden'].authenticate!

		u = env['warden'].user

		newItem = SaleItem.new
		newItem.title = params[:title]
		newItem.description = params[:description]
		newItem.userid = u.id
		newItem.price = params[:price]
	
		if ! params[:image].nil?
  			filetype = params[:image][:type].gsub('image/', '')
  			filename = u.id.to_s+rand(36**6).to_s(36)+"."+filetype
  			File.open("public/uploads/"+ filename, "wb") do |f|
  			  f.write(params['image'][:tempfile].read)
  			end
  			newItem.images = filename

		end

		newItem.save

		flash.success = "Item successfully created"

		redirect '/user/items'
	end
	
	get '/saleitem/edit/:id' do |id|
		env['warden'].authenticate!
		u = env['warden'].user
		item = SaleItem.get(id)
		
		unless u.id.to_s == item.userid.to_s or admin?(u)
			flash.error = "You do not have permission to view that page"
			redirect '/'
		end

		slim :edit_item, :locals => { :item => item }

	end

	post '/saleitem/edit/:id' do |id|
		env['warden'].authenticate!
		item = SaleItem.get(id)
		puts params[:delete]
		#destroy from edit page
		if params[:delete] == "Delete"
			item = SaleItem.get(id)
			item.destroy			
			flash.success = "Item successfully destroyed"
			redirect '/user/items'			
		end

		item.update(:title => params[:title], :description => params[:description], :price => params[:price], :sale_status =>params[:sale_status] )
		redirect '/user/items'
	end

	post '/saleitem/destroy/:id' do |id|
		item = SaleItem.get(id)
		item.destroy

		flash.success = "Item successfully destroyed"
		redirect '/user/items'
	end

	get '/saleitem/:id' do |id|
		item = SaleItem.get(id)
		u = User.get(item.userid)
		
		session["current_item_id"] = id
		puts session["access_token"]
		baseURL = base_url
		unless item.nil?
			slim :show_item, :locals => { :item => item, :u => u, :baseURL => baseURL }
		else
			slim :not_found
		end
	end
	post '/completePurchase' do
		item_id = params["item_id"]
		referer_id = URI(request.referer).path.gsub('/saleitem/','')
		if item_id != referer_id
			flash.error = "Can't do that"
			redirect '/'
		end
		
		item = SaleItem.get(item_id)
		if item.sale_status != "for_sale"
			flash.error = "Item not for sale."
			redirect '/'
		end
		
		user = User.get(item.userid)
		access_token = session["access_token"]
		puts access_token
		uri = URI("https://api.venmo.com/v1/payments")
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true
		note = "Payment for "+item.title
		args = "access_token=#{access_token}&amount=0.01&email=#{user.email}&note=#{note}"	
		#args = "access_token=#{access_token}&amount=#{item.price}&email=#{user.email}&note=#{note}"	
		response = https.post(uri.path, args) 

		item.update({:sale_status => "sold"})
		flash.success = "You successfully purchased #{item.title}"
		redirect  '/'
		puts response.body

	end
	get '/item/:id' do |id|
		item = SaleItem.get(id)
		u = User.get(item.userid)
		unless item.nil?
			slim :show_item, :locals => { :item => item, :u => u }
		else
			slim :not_found
		end
	end
end