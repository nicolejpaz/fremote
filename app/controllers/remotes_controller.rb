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

    if params.has_key?("remote")
    	if params["remote"].has_key?("admin_only")
    		@owner_only = to_boolean(params["remote"]["admin_only"])
    	end
    end

		if @remote.admin_only == false || @remote_owner
			@remote.status = params["status"] if params["status"]
			@remote.start_at = params["start_at"].to_i if params["start_at"]
      @remote.admin_only = @owner_only
			@remote.save
			ActiveSupport::Notifications.instrument("control:#{@remote.remote_id}", {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'sender' => params['sender'] }.to_json)
		end
    render nothing: true
	end

	def show
		@user = current_user if current_user

		@remote = Remote.find_by({remote_id: params[:id]})

		@remote_json = @remote.to_json
	end


end
