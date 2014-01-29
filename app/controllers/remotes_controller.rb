class RemotesController < ApplicationController
	def new
		@remote = Remote.new
	end

	def create
		@remote = Remote.new
		dispatch = @remote.populate(params[:video_url])
		
		@remote.save
		redirect_to root_path
		flash[dispatch[:status]] = dispatch[:message]
	end
end
