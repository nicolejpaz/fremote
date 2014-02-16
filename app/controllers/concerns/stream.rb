module Stream
  def self.start(notifications, heartrate = 20, response)
    response.headers['Content-Type'] = 'text/event-stream'

    queue = []

    # Subscribe the current user to notifications.
    notifications.each do |notification|
      ActiveSupport::Notifications.subscribe(notification) do |name, start, finish, id, payload|
          queue << {name: name, payload: payload}
      end
    end


    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    heartbeat = Thread.new do
        loop do
          sleep heartrate.seconds
          response.stream.write "event: heartbeat\n"
        end
    end

    # Loop until the heartbeat dies.
    while heartbeat.alive?
      sleep 0.1.seconds
      response.stream.write "event: #{queue.first[:name]}\ndata: #{queue.first[:payload]} \n\n" unless queue.count == 0
      queue.shift
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
    rescue IOError
    ensure
      notifications.each do |notification|
        ActiveSupport::Notifications.unsubscribe(notification)
      end
      response.stream.close
      p "stream closed"
  end
end