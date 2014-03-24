class ErrorsController < ApplicationController
 
  def not_found
    render 'errors/404_not_found'
  end

  def unprocessable_entity
    render 'errors/422_unprocessable_entity'
  end

  def internal_server_error
    render 'errors/500_internal_server_error'
  end
 
protected
 
  def status_code
    params[:code] || 500
  end
 
end
