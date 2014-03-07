class PlaylistsController < ApplicationController

  def show
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    @playlist = @remote.playlist
    render json: @playlist.list.to_json
  end

  def update
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    @playlist = @remote.playlist
    if @remote.authorization.is_authorized?("playlist", @user)
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => true}.to_json)
      @playlist.sort_list_item(params[:old_position].to_i, params[:new_position].to_i, @user)
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => false}.to_json)
    end
    render nothing: true
  end

  def create
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    @playlist = @remote.playlist
    if @remote.authorization.is_authorized?("playlist", @user)
      new_media = Media.new(params[:url])
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => true}.to_json)
      @playlist.add_list_item(new_media)
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => false}.to_json)
    end
    render nothing: true
  end

  def destroy
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    @playlist = @remote.playlist
    if @remote.authorization.is_authorized?("playlist", @user)
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => true}.to_json)
      @playlist.delete_list_item(params[:index])
      Notify.new("playlist_block:#{@remote.remote_id}", {"block" => false}.to_json)
    end
    render nothing: true
  end

  private

  def push_link_to_playlist(url, new_video)
    new_media = Media.new(url)
    self.list << new_media unless nil
  end

end
