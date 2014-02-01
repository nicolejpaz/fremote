class RemotesController < ApplicationController
	# include ActionController::Live

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

	def update
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote.status = params["status"]
		@remote.start_at = params["start_at"].to_i
		@remote.save

    render json: {rammstein:"mein land"}.to_json
	end

	def show
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_json = @remote.to_json
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
