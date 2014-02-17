class RemotesController < ApplicationController

  include RemotesHelper

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

		if dispatch[:status] == :success
			flash[:notice] = dispatch[:message]
			redirect_to remote_path(@remote.remote_id)
		else
			flash[:alert] = dispatch[:message]
			redirect_to root_path
		end

	end

	def update
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    @owner_only = false

    if params.has_key?("remote") && params["remote"].has_key?("admin_only")
    		@owner_only = to_boolean(params["remote"]["admin_only"])
    end

		if @remote.admin_only == false || @remote_owner
			@remote.status = params["status"] if params["status"]
			@remote.start_at = params["start_at"].to_i if params["start_at"]
      @remote.admin_only = @owner_only
			@remote.save
			ActiveSupport::Notifications.instrument("control:#{@remote.remote_id}", {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'] }.to_json)
		end
    render nothing: true
	end

	def ping
		@remote = Remote.find_by({remote_id: params[:id]})
		ActiveSupport::Notifications.instrument("control:#{@remote.remote_id}", {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'dispatched_at' => Time.now, 'sender_id' => 'fremote_server' }.to_json)
		render nothing: true
	end

	def show
		@user = current_user if current_user

		@remote = Remote.find_by({remote_id: params[:id]})

		@remote_owner = @user if @user == @remote.user

		@remote_json = @remote.to_json

		@identifier = (Time.now.strftime('%Y%m%d%H%M%S%L%N') + rand(400).to_s).to_s

		@temp_name = $funny_names["names"][rand($funny_names["names"].length - 1)] + $funny_names["surnames"][rand($funny_names["surnames"].length - 1)] + rand(99).to_s

		if @user
			@username = @user.name
			@person_registered = true
		else
			@username = @temp_name
			@person_registered = false
		end

	end

	def chat
			@remote = Remote.find_by({remote_id: params[:id]})
			ActiveSupport::Notifications.instrument("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] }.to_json)
			render nothing: true
	end

	def time
		render json: {time: Time.now}.to_json
	end

end
