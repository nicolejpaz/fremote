class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user
    @username = ( @user.name if @user ) || cookies[:username]
    @user_kind = @remote.kind_of_user(@user)
    Stream.start(["control", "chat", "drawing", "clear", "playlist_add", "playlist_sort", "playlist_delete", "playlist_block", "playlist_clear", "playlist_play", "playlist_votes", "watch", "unwatch"], 10, response, @remote, @username, @user_kind)
  end

end
