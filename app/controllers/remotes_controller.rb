class RemotesController < ApplicationController

  include RemotesHelper

	def new
		@remote = Remote.new
	end

	def create
		@user = current_user if current_user
		@remote = Remote.make(@user)
		dispatch = @remote.populate(params[:video_url])
		@remote.admin_only = params[:admin_only] || false
		@remote.save
		flash[dispatch[:status]] = dispatch[:message]
		redirect_to dispatch[:path]
	end

	def update
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    @remote.update(params, @remote_owner)
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
		@username = Chat.guest_display_name
	end

	def chat
		@remote = Remote.find_by({remote_id: params[:id]})
		ActiveSupport::Notifications.instrument("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] }.to_json)
		render nothing: true
	end

	def time
		render json: {time: Time.now}.to_json
	end

	def drawing
		@remote = Remote.find_by({remote_id: params[:id]})
		ActiveSupport::Notifications.instrument("drawing:#{@remote.remote_id}", {'x_coordinate' => params["x_coordinate"], 'y_coordinate' => params["y_coordinate"] }.to_json)
		render nothing: true
	end

end
