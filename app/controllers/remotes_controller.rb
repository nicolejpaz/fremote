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

		ActiveSupport::Notifications.instrument(@remote.remote_id, extra: :information) do
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
				response.stream.write "data: hello world \n\n"
		end
		sleep(30.seconds)
		rescue IOError
  			p "Client Disconnected"
		ensure
			p "client disconnected"
			ActiveSupport::Notifications.unsubscribe(params[:id])
			response.stream.close
	end

end
