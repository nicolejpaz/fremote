module RemotesHelper
  def to_boolean(str)
    if str.to_s.downcase == "true" || str.to_s.downcase == "1"
      true
    elsif str.to_s.downcase == "false" || str.to_s.downcase == "0"
      false
    else
      nil
    end
  end

  def is_authorized?(remote, user = nil)
    if user == remote.user || remote.admin_only == false
      return true
    else
      return false
    end
  end

  def sanitized_name(user)
    user_name = user.name.split(' ')
    return user_name.join('_')
  end

end
