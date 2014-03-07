class DrawingsController < ApplicationController
  def update
    @remote = Remote.find_by({remote_id: params[:id]})
    @user = current_user if current_user

    if @remote.authorization.is_authorized?("draw", @user)
      Notify.new("drawing:#{@remote.remote_id}", {'coordinates' => params['coordinates']})
    end

    render nothing: true
  end

  def write
    @user = current_user if current_user
    @remote = Remote.find_by({remote_id: params[:id]})
    @drawing = @remote.drawing

    if @remote.authorization.is_authorized?("draw", @user)
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

    if @remote.authorization.is_authorized?("draw", @user)
      @drawing.coordinates = []
      @drawing.save
      Notify.new("clear:#{@remote.remote_id}")
    end

    render nothing: true
  end

  private 

end