class Api::V1::UserController < ApplicationController
		respond_to :json
	#Create account : email and password params required
	def create
		userParams = params.require(:user).permit([:email, :password])

		user = User.find_by_email(userParams[:email])

		if(user.nil?)
			userParams[:password] = Digest::MD5.hexdigest(userParams[:password])
			user = User.new userParams
			user.save
			render json: { success: true}, :status => 204, callback: params[:callback]
		else
			render json: { success: false, reason: "User already exists", errno: -1 }, callback: params[:callback]
		end
	end

	def connect
		userParams = params[:user]

		user = User.find_by_email(userParams[:email])

		if(!user.nil?)
			password = Digest::MD5.hexdigest(userParams[:password])

			if(user.password.eql?(password))
				#User credentials are correct, now we generate a token which will be used for every other api call
				token = Token.new
				token.value = Digest::MD5.hexdigest(password+Digest::SHA256.hexdigest(Time.zone.now.to_s))
				token.expires_at = Time.zone.now+30.days
				token.user = user
				token.save
				render json: { success: true, :token => token.as_json({:only => [:value, :expires_at]})}, callback: params[:callback]
			else
				render json: { success: false, reason: "Invalid password", errno: -3 }, callback: params[:callback]
			end
		else
			render json: { success: false, reason: "User not found", errno: -2 }, callback: params[:callback]
		end
	end
end
