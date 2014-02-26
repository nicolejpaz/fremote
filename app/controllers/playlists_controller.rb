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
    @playlist.sort_list_item(params[:old_position].to_i, params[:new_position].to_i, @user)
    render nothing: true
  end

  def create
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    @playlist = @remote.playlist
    new_media = Media.new(params[:url])
    @playlist.list << new_media if new_media
    Notify.new("playlist_add:#{@remote.remote_id}", {'media' => new_media })
    render nothing: true
  end

  private

  def push_link_to_playlist(url, new_video)
    new_media = Media.new(url)
    self.list << new_media unless nil
  end

end
