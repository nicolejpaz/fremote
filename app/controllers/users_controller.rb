class UsersController < ApplicationController
  def show
    @user_viewed = User.find_by({name: params[:id]})
    @remotes = Remote.where({user: @user_viewed})
  end
end