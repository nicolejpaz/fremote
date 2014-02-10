class RemotesController < ApplicationController
	include ActionController::Live

	def new
		@remote = Remote.new
	end

	def create
		@user = current_user if current_user
		if @user
			@remote = @user.remotes.new
		else
			@remote = Remote.new
		end

		dispatch = @remote.populate(params[:video_url])
		@remote.admin_only = params[:admin_only] || false
		@remote.save
		flash[:success] = dispatch[:message]

		if dispatch[:status] == :success
			redirect_to remote_path(@remote.remote_id)
		else
			redirect_to root_path
		end

	end

	def update
		@user = current_user if current_user
		if @user
			@remote = @user.remotes.find_by({remote_id: params[:id]})
		else
			@remote = Remote.find_by({remote_id: params[:id]})
		end
		if @remote.admin_only == true && @user || @remote.admin_only == false
			@remote.status = params["status"]
			@remote.start_at = params["start_at"].to_i
			@remote.save
			ActiveSupport::Notifications.instrument(@remote.remote_id, {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'sender' => params['sender'] }.to_json) do
			end
		end
    render json: {}.to_json
	end

	def show
		@user = current_user if current_user
		# if @user
		# 	@remote = @user.remotes.find_by({remote_id: params[:id]})
		# else
			@remote = Remote.find_by({remote_id: params[:id]})
		# end
		@remote_json = @remote.to_json
	end

	def stream
    response.headers['Content-Type'] = 'text/event-stream'

    # Subscribe the current user to notifications.
    ActiveSupport::Notifications.subscribe(params[:id]) do |name, start, finish, id, payload|
    		@event = params[:id]
        @payload = payload
    end

    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    heartbeat = Thread.new do
        loop do
          sleep 10.seconds
          response.stream.write "event: heartbeat\n"
        end
    end

    # Loop until the heartbeat dies.
    while heartbeat.alive?
      sleep 0.1.seconds
      response.stream.write "event: #{@event}\ndata: #{@payload} \n\n" unless @payload == nil
      @payload = nil
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      ActiveSupport::Notifications.unsubscribe(params[:id])
      response.stream.close
      p "stream closed"
	end

end
