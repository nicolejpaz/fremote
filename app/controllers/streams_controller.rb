class StreamsController < ApplicationController
  include ActionController::Live

  def stream
    @event = params[:id]
    @chat_event = "control:#{params[:id]}"
    response.headers['Content-Type'] = 'text/event-stream'

    # Subscribe the current user to notifications.
    ActiveSupport::Notifications.subscribe("control:#{params[:id]}") do |name, start, finish, id, payload|
        @payload = payload
    end

    ActiveSupport::Notifications.subscribe("chat:#{params[:id]}") do |name, start, finish, id, payload|
        @chat_payload = payload
    end

    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    heartbeat = Thread.new do
        loop do
          sleep 30.seconds
          response.stream.write "event: heartbeat\n"
        end
    end

    # Loop until the heartbeat dies.
    while heartbeat.alive?
      sleep 0.1.seconds
      response.stream.write "event: #{@event}\ndata: #{@payload} \n\n" unless @payload == nil
      response.stream.write "event: #{@chat_event}\ndata: #{@chat_payload} \n\n" unless @chat_payload == nil
      @payload,@chat_payload = nil
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      ActiveSupport::Notifications.unsubscribe("control:#{params[:id]}")
      ActiveSupport::Notifications.unsubscribe("chat:#{params[:id]}")
      response.stream.close
      p "stream closed"
  end

end
