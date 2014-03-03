class RemotesController < ApplicationController

  include RemotesHelper

	def new
		@remote = Remote.new
	end

	def create
		@user = current_user if current_user
		@remote = Remote.make(@user)
		dispatch = @remote.populate(params[:video_url])
		@remote.name = params[:name] unless params[:name] == ''
		@remote.description = params[:description] unless params[:description] == ''
		@remote.admin_only = to_boolean(params[:admin_only]) || false
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
		@playlist = @remote.playlist
		render json: {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.updated_at, 'dispatched_at' => Time.now, 'sender_id' => 'fremote_server', 'selection' => @playlist.selection, 'stream_url' => URI::encode(ViddlRb.get_urls(@playlist.list[@playlist.selection]["url"]).first), 'playlist' => @playlist.list, 'watchers' => @remote.watchers }.to_json
	end

	def show
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
		@remote_json = @remote.json
		@identifier = (Time.now.strftime('%Y%m%d%H%M%S%L%N') + rand(400).to_s).to_s
		@username = Chat.guest_display_name(@user, params[:guest_name])
		cookies[:username] = @username
		@playlist = Playlist.new
		@remote_name = @remote.name
		@remote_description = @remote.description
    @guest_name = Object.new
		render Remotes.what_to_render(@user, params[:guest_name])
	end

	def time
		render json: {time: Time.now}.to_json
	end

end
