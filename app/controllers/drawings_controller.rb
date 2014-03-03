class DrawingsController < ApplicationController
  def update
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user

    if is_authorized?(@remote, @user)
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

  def read
    @remote = Remote.find_by({remote_id: params[:id]})
    @coordinates = @remote.drawing.coordinates

    if @coordinates.length > 0
      render json: @coordinates.to_json
    else
      render nothing: true
    end
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

  private 
  def is_authorized?(remote, user = nil)
    if user == remote.user || remote.admin_only == false
      return true
    else
      return false
    end
  end
end