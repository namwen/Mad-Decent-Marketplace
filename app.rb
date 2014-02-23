require 'bundler/setup'
require 'rack-flash'
require 'slim'
Bundler.require

class MyApp < Sinatra::Application
	use Rack::Session::Cookie, secret: "hsdfbvfu%32kjbfn_09d"
	use Rack::Flash, accessorize: [:error, :success]

  	use Warden::Manager do |config|
	
  	  config.serialize_into_session{|user| user.id }
	
  	  config.serialize_from_session{|id| User.get(id) }
	
  	  config.scope_defaults :default,
  	    strategies: [:password],
  	    action: 'auth/unauthenticated',
  	    flash: Rack::Flash
  	  config.failure_app = self
  	end

	Warden::Manager.before_failure do |env,opts|
    	env['REQUEST_METHOD'] = 'POST'
 	end

	Warden::Strategies.add(:password) do
	    def valid?
	      params['username'] && params['password']
	    end

	    def authenticate!
	      user = User.first(username: params['username'])

	      if user.nil?
	        fail!("The username you entered does not exist.")
	      elsif user.authenticate(params['password'])
	        success!(user)
	      else
	        fail!("Could not log in")
	      end
	    end
	end

	helpers do
		
		def admin? currentUser 
			if currentUser.nil?
				return false
			end

			if currentUser.user_group == "administrator"
				return true
			end
				
			return false
		end
		def base_url
    		@base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  		end
	end


end

require_relative 'models/init'
require_relative 'routes/init'

# admin = User.new(:id => 1, :username => "admin", :email => "wnewman88@gmail.com", :password => "notSecure", :user_group => "administrator" )
# admin.save
