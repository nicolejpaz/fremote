class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @remote = Remote.find_by({remote_id: params[:id]})
    @username = Chat.guest_display_name
    Stream.start(["control", "chat", "drawing", "clear", "playlist_add", "playlist_sort", "playlist_delete", "playlist_block", "watch", "unwatch"], 10, response, @remote, @username)
  end

end
