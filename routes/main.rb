require 'net/http'

class MyApp < Sinatra::Application
	get '/' do
		u = env['warden'].user
		if !u.nil?
			saleItems = SaleItem.all(:userid => u.id )
		end

		
		slim :index, :locals => { :u => u, :items => saleItems }
	
	end

	get '/lol' do 

		access_token = params["access_token"]
		redirect_id = session["current_item_id"]
		session["access_token"] = params["access_token"]
		puts session["access_token"]
		redirect "/saleitem/#{redirect_id}"

		# uri = URI("https://api.venmo.com/v1/payments")
		# https = Net::HTTP.new(uri.host, uri.port)
		# https.use_ssl = true
		# args = "access_token=#{access_token}&amount=0.01&email=shreyas.jaganmohan@gmail.com&note=retarded"

		# response = https.post(uri.path, args) 
		# puts response.body

	end


end