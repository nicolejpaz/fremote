class RemotesController < ApplicationController
	include ActionController::Live

	def new
		@remote = Remote.new
		ActiveSupport::Notifications.instrument('render', extra: :information) do
		end
	end

	def create
		@remote = Remote.new
		dispatch = @remote.populate(params[:video_url])

		@remote.save
		flash[:success] = dispatch[:message]
		if dispatch[:status] == :success
			redirect_to remote_path(@remote.remote_id)
		else
			redirect_to root_path
		end
	end

	def show
		@remote = Remote.find_by({remote_id: params[:id]})
		# response.headers['Content-Type'] = 'text/event-stream'
		# ActiveSupport::Notifications.subscribe("render") do |*args|
		# 		response.stream.write "hello world\n"
		# end
		# sleep
		# rescue IOError
  # 			p "Client Disconnected"
		# ensure
		# 	response.stream.close
	end

end
