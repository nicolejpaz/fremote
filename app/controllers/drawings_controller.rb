class DrawingsController < ApplicationController
  def create
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user

    if @user == @remote.user || @remote.admin_only == false
      Notify.new("drawing:#{@remote.remote_id}", {'coordinates' => params["coordinates"]})
    end

    render nothing: true
  end
end