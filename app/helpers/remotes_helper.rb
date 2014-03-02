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
    if remote.admin_only == false
      return true
    elsif user == remote.user
      return true
    end
    return false
  end

  def sanitized_name(user)
    return user.name.sub(' ', '_')
  end

end
