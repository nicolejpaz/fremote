class ChatController < ApplicationController

  def create
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    Notify.new("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] })
    render nothing: true
  end

end
