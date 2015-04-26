class Note < ActiveRecord::Base

	belongs_to :user

	EXPORT_OPTIONS = { :except => [:user_id]}
end
