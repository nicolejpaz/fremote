class ChatController < ApplicationController

  def create
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:remote_id]})
    if is_authorized?(@remote, @user)
      Notify.new("chat:#{@remote.remote_id}", {'message' => params["chat_message"], 'name' => params["username"] })
    end
    render nothing: true
  end

  private
  def is_authorized?(remote, user = nil)
    if user == remote.user || remote.admin_only == false
      return true
    else
      return false
    end
  end
end
