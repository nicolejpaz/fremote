module Stream

  def self.start(notifications, heartrate = 20, response, remote, username, user_kind)
    response.headers['Content-Type'] = 'text/event-stream'

    # Send 2kb of filler at beginning of request for EventSource polyfill compatibility with IE.
    # response.write(":" + Array(2049).join(" ") + "\n")
    response.stream.write ":#{' ' * 2049}\n"

    # Initialize our notification queue.
    queue = []

    # Subscribe the current user to notifications.
    notifications.each do |notification|
      ActiveSupport::Notifications.subscribe("#{notification}:#{remote.remote_id}") do |name, start, finish, id, payload|
        queue << {name: name, payload: payload}
      end
    end

    # Separate thread creates a heartbeat to "ping" the user every few seconds.  When a user closes
    # their window and the thread tries to send it a heartbeat event, the loop will error out and
    # cause the thread to die.
    # This thread also notifies the server and clients whether or not a person is viewing a remote.
    heartbeat = Thread.new do
      remote.watchers = [] if ENV['server_mode'] == '1'
      remote.save
      ENV['server_mode'] = '0'

      # Define lambdas that are called to add and remote watchers from the watcher list.
      watch = lambda { |remote, username, user_kind|
        remote = remote.reload
        watcher_record = {"username" => username, "user_kind" => user_kind}
        remote.watchers << watcher_record
        remote.save
        ActiveSupport::Notifications.instrument("watch:#{remote.remote_id}", {watchers: remote.watchers.uniq, username: username}.to_json)
      }

      unwatch = lambda { |remote, username|
        remote = remote.reload
        watcher_index = remote.watchers.index(remote.watchers.select{ |i| i["username"] == username}.first)
        remote.watchers.delete_at(watcher_index)
        remote.save
        ActiveSupport::Notifications.instrument("unwatch:#{remote.remote_id}", {watchers: remote.watchers.uniq, username: username}.to_json)
      }
      begin
        watch.call(remote, username, user_kind)
        loop do
          sleep heartrate.seconds
          response.stream.write "event: heartbeat\n"
        end
      ensure
        unwatch.call(remote, username)
      end
    end

    # Loop until the heartbeat dies.
    while heartbeat.alive? && response.stream.closed? == false
      sleep 0.1.seconds
      response.stream.write "event: #{queue.first[:name]}\ndata: #{queue.first[:payload]} \n\n" unless queue.count == 0
      queue.shift
    end

    # Make sure that the stream is closed and the current process is unsubscribed.
  rescue IOError
  ensure
    notifications.each do |notification|
      ActiveSupport::Notifications.unsubscribe("#{notification}:#{remote.id}")
    end
    response.stream.close
    p "stream closed"
  end

end