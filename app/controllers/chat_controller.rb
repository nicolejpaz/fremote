class ChatController < ApplicationController

  def create
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    if @remote.authorization.is_authorized?("chat", @user)
      Notify.new("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] })
    end
    render nothing: true
  end

  private

end
