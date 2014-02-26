class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @remote = Remote.find_by({remote_id: params[:id]})
    Stream.start(["control", "chat", "drawing", "clear", "playlist_add", "playlist_sort"], 10, response, @remote)
  end

end
