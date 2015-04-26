class Api::V1::NoteController < ApplicationController
	respond_to :json
	before_filter	:authentify

	before_filter :get_note, :only => [:show, :update, :destroy]

	def authentify
		token = Token.includes(:user).find_by_value(params[:token])

		if(token.nil?)
			render json: { 
				success: false , 
				reason: "Invalid token", 
				errno: -4
			}, callback: params[:callback]
			return false
		else
			if(token.expires_at>Time.zone.now)
				@user = token.user
				return true
			else
				token.destroy

				render json: { 
				success: false , 
				reason: "Token expired", 
				errno: -5
			}, callback: params[:callback]
			end
		end
	end

	def get_note
		@note = @user.notes.find_by_id(params[:id])

		if(@note.nil?)
			render json: { 
				success: false , 
				reason: "Note doesn't exist", 
				errno: -6
			}, callback: params[:callback]
			return false
		else
			return true
		end

	end

	def index
		render json: Oj.dump({ 
			:success => true, 
			:notes => @user.notes.order("created_at desc").as_json(Note::EXPORT_OPTIONS)
		}, mode: :compat), callback: params[:callback]
	end

	def create
		noteParams = params.require(:note).permit([:title, :content])
		note = Note.new noteParams
		note.user = @user
		note.save

		render json: Oj.dump({ 
			:success => true, 
			:note => note.as_json(Note::EXPORT_OPTIONS)
		}, mode: :compat), callback: params[:callback]
	end

	def update
		noteParams = params.require(:note).permit([:title, :content])
		@note.update_attributes(noteParams)

		render json: Oj.dump({ 
			:success => true, 
			:note => @note.as_json(Note::EXPORT_OPTIONS)
		}, mode: :compat), callback: params[:callback]
	end

	def show
		render json: Oj.dump({ 
			:success => true, 
			:note => @note.as_json(Note::EXPORT_OPTIONS)
		}, mode: :compat), callback: params[:callback]
	end

	def destroy
		@note.destroy
		render json: Oj.dump({ 
			:success => true, 
			:status => "deleted"
		}, mode: :compat), callback: params[:callback]
	end


end
