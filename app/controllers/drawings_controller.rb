class DrawingsController < ApplicationController
  def update
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user

    if @user == @remote.user || @remote.admin_only == false
      Notify.new("drawing:#{@remote.remote_id}", {'coordinates' => params['coordinates']})
    end

    render nothing: true
  end

  def write
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:id]})
    @drawing = @remote.drawing

    if @user == @remote.user || @remote.admin_only == false
      @drawing.save_to_database(params[:coordinates])
    end

    render nothing: true
  end
  
  def clear
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user
    @drawing = @remote.drawing

    if @user == @remote.user || @remote.admin_only == false
      @drawing.coordinates = []
      @drawing.save
      Notify.new("clear:#{@remote.remote_id}")
    end

    render nothing: true
  end
end