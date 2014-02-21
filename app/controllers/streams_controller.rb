class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @control_event = "control:#{params[:id]}"
    @chat_event = "chat:#{params[:id]}"
    @remote = Remote.find_by({remote_id: params[:id]})
    Stream.start([@control_event, @chat_event], 10, response, @remote)
  end

end
