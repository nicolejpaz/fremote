class Authorization
  PERMISSIONS_TEMPLATE = {"control" => "1", "chat" => "1", "playlist" => "1", "draw" => "1", "settings" => "1"}
  include ActionView::Helpers::FormHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_guest, type: Hash, default: PERMISSIONS_TEMPLATE.dup
  field :_user, type: Hash, default: PERMISSIONS_TEMPLATE.dup
  field :_member, type: Hash, default: PERMISSIONS_TEMPLATE.dup
  embedded_in :remote

  def is_authorized?(permission, user = nil)
    kind = kind_of_entity(user)
    if user == self.remote.user
      return true
    else
      to_boolean(self[kind][permission])
    end
  end

  def permissions_by_user_type(permission)
    authorized = {}
    authorized[:guest] = to_boolean(self[:_guest][permission])
    authorized[:user] = to_boolean(self[:_user][permission])
    authorized[:member] = to_boolean(self[:_member][permission])
    authorized[:owner] = to_boolean("1")
    return authorized
  end

  def update_permissions(params)
    unless params[:quick_remote] == "true"
      default_permissions = zero_permissions(PERMISSIONS_TEMPLATE.dup)
      self._guest = default_permissions.merge(params["_guest"] || {})
      self._user = default_permissions.merge(params["_user"] || {})
      self._member = default_permissions.merge(params["_member"] || {})
    end
  end

  def active_or_inactive(kind, permission)
    return "active" if self[kind][permission] == "1"
    return "inactive" if self[kind][permission] == "0"
  end

  private

  def zero_permissions(permissions)
    permissions.map{|key,value| permissions[key] = "0"}
    return permissions.dup
  end

  def kind_of_entity(user = nil)
    if user
      if self.remote.member_list.members.include?(user.id)
        return :_member
      elsif user.is_a?(User)
        return :_user
      end
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