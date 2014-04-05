class RemotesController < ApplicationController

  include RemotesHelper

	def index
		@remote = Remote.new
	end

	def new
    if current_user
  		@user = current_user
  		@remote = Remote.new
      redirect_to root_path unless @remote.authorization.is_authorized?("settings", @user)
    else
      redirect_to root_path
    end
	end

	def create
		@user = current_user if current_user
		@remote = Remote.make(@user)
    @remote.authorization.update_permissions(params) if @user
    if params[:video_url]
  		dispatch = @remote.populate(params[:video_url])
    else
      dispatch = @remote.populate_with_options(params, @user)
    end
    flash[dispatch[:status]] = dispatch[:message]
    redirect_to dispatch[:path]
	end

	def edit
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
		@remote_owner = @user if @user == @remote.user
		@members = @remote.member_list.members
    render "permission_denied" unless @remote.authorization.is_authorized?("settings", @user)
	end

	def update
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote.update(params) if @remote.authorization.is_authorized?("settings", @user)
    respond_to do |format|
      format.json { render json: {'remote' => @remote}.to_json }
      format.html { redirect_to remote_path(@remote) }
    end
	end

	def control
		@user = current_user if current_user
		@remote = Remote.find_by({remote_id: params[:id]})
    @remote_owner = @user if @user == @remote.user
    @remote.control(params, @remote_owner) if @remote.authorization.is_authorized?("control", @user)
    render nothing: true
	end

	def ping
		@remote = Remote.find_by({remote_id: params[:id]})
		@playlist = @remote.playlist
    result = {'start_at' => @remote.start_at, 'status' => @remote.status, 'updated_at' => @remote.last_controlled_at.to_s, 'dispatched_at' => Time.now, 'sender_id' => 'fremote_server', 'selection' => @playlist.selection, 'stream_url' => URI::encode(Media.link(@playlist.list[@playlist.selection]["url"])), 'playlist' => @playlist.list, 'watchers' => @remote.watchers, 'playing' => @playlist.playing }
    render json: result.to_json
	end
  
  def change
    @remote = Remote.find_by({remote_id: params[:id]})
    @votes_to_skip = @remote.watchers.length / 3
    @remote.playlist.votes += 1
    @remote.playlist.save
    @remote.save
    @votes_to_skip = 1 if @votes_to_skip == 0
    Notify.new("playlist_votes:#{@remote.remote_id}", {"votes" => @remote.playlist.votes}.to_json)
    @remote.skip if @remote.playlist.votes >= @votes_to_skip

    render nothing: true
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
    @remote_votes = @remote.playlist.votes
    @guest_name = Object.new
    render Remotes.what_to_render(@user, params[:guest_name])
	end

	def time
		render json: {time: Time.now.utc.to_s}.to_json
	end
end
