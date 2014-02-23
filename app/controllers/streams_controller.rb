class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @control_event = "control:#{params[:id]}"
    @chat_event = "chat:#{params[:id]}"
    @drawing_event = "drawing:#{params[:id]}"
    @clear_event = "clear:#{params[:id]}"
    @remote = Remote.find_by({remote_id: params[:id]})
    Stream.start([@control_event, @chat_event, @drawing_event, @clear_event], 10, response, @remote)
  end

end
