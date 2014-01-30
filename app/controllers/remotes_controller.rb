class RemotesController < ApplicationController
	def new
		@remote = Remote.new
	end

	def create
		@remote = Remote.new
		dispatch = @remote.populate(params[:video_url])
		
		@remote.save
		if dispatch[:status] == :success
			redirect_to remote_path(@remote.remote_id)
			flash[dispatch[:status]] = dispatch[:message]
		else
			redirect_to root_path
			flash[dispatch[:status]] = dispatch[:message]
		end
	end

	def show

	end

end
