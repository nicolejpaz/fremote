class UsersController < ApplicationController
  def show
    @unsanitized_username = params[:id].sub('+', ' ')

    @user_viewed = User.find_by({name: @unsanitized_username})
    @remotes = Remote.where({user: @user_viewed})
    
    @memberships = @user_viewed.membership.remote_ids
    @memberships.map! do |remote_id|
      Remote.find_by({remote_id: remote_id})
    end
  end
end