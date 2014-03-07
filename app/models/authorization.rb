class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_guest, type: Hash, default: {"control" => "1", "chat" => "1", "playlist" => "1", "draw" => "1", "settings" => "1"}
  field :_user, type: Hash, default: {"control" => "1", "chat" => "1", "playlist" => "1", "draw" => "1", "settings" => "1"}
  field :_member, type: Hash, default: {"control" => "1", "chat" => "1", "playlist" => "1", "draw" => "1", "settings" => "1"}
  embedded_in :remote

  def is_authorized?(permission, user = nil)
    kind = kind_of_entity(user)
    if user == self.remote.user
      return true
    else
      to_boolean(self[kind][permission])
    end
  end

  def update_permissions(params)
    self._guest = params["_guest"] unless params["_guest"] == nil
    self._user = params["_user"] unless params["_user"] == nil
    self._member = params["_member"] unless params ["_member"] == nil
  end

  private

  def kind_of_entity(user = nil)
    # if self.remote.members.contains?(user)
    #   return :_member
    # elsif user.is_a?(User)
    #   return :_user
    # else
    #   return :_guest
    # end

    if user.is_a?(User)
      return :_user
    else
      return :_guest
    end

  end

  def to_boolean(str)
    if str.to_s.downcase == "true" || str.to_s.downcase == "1" || str.to_s.downcase == "yes"
      true
    elsif str.to_s.downcase == "false" || str.to_s.downcase == "0" || str.to_s.downcase == "no" || str == nil 
      false
    else
      nil
    end
  end

end