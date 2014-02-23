require 'rubygems'
require 'bcrypt'
require 'data_mapper'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'


DataMapper.setup :default, "sqlite3:///Users/Will/LocalHost/buysell/db.db"

class User
	include DataMapper::Resource
	include BCrypt

	property :id 		,	Serial	, :key => true
	property :username	, 	String	, :length => 3..30, :unique => true, :required => true
	property :email 	, 	String	, :length => 5..200, :required => true, :format => :email_address
	property :password	, 	BCryptHash
	property :user_group,	String	, :default => "user"


	def authenticate(attempted_password)
		if self.password == attempted_password
			true
		else
			false
		end
	end
end

class SaleItem
	include DataMapper::Resource

	property :id 			,	Serial	, :key => true
	property :userid		, 	String	
	property :title			, 	String	, :length => 3..45
	property :description	,	Text
	property :price			,	String	
	property :sale_status	,	String	, :default => "for_sale"
	property :images		,	String
	property :created_at	, 	DateTime
	property :updated_at	, 	DateTime


#	belongs_to :user

end

DataMapper.finalize

DataMapper.auto_upgrade!