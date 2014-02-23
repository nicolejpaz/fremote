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

end
