class UsersController < ApplicationController
  def show
    @sanitized_username = params[:id].sub('_', ' ')

    @user_viewed = User.find_by({name: @sanitized_username})
    @remotes = Remote.where({user: @user_viewed})
  end
end