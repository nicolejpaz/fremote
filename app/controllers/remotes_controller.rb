class RemotesController < ApplicationController
	include ActionController::Live

	def new
		@remote = Remote.new
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
		ActiveSupport::Notifications.instrument(@remote.remote_id, {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'sender' => params['sender'] }.to_json) do
		end
    render json: {rammstein:"mein land"}.to_json
	end

	def show
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_json = @remote.to_json
	end

	def stream
		response.headers['Content-Type'] = 'text/event-stream'
		ActiveSupport::Notifications.subscribe(params[:id]) do |name, start, finish, id, payload|
				response.stream.write "event: #{params[:id]}\n"
				response.stream.write "data: #{payload} \n\n"
		end
		loop do
			sleep 10.seconds
			response.stream.write "event: heartbeat\n"
		end
		rescue IOError
  			p "Client Disconnected"
		ensure
			ActiveSupport::Notifications.unsubscribe(params[:id])
			response.stream.close
	end

end
