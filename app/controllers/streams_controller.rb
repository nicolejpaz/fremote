class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user
    @username = ( @user.name if @user ) || cookies[:username]
    Stream.start(["control", "chat", "drawing", "clear", "playlist_add", "playlist_sort", "playlist_delete", "playlist_block", "watch", "unwatch"], 10, response, @remote, @username)
  end

end
