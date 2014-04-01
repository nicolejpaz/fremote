module RemotesHelper
  def to_boolean(str)
    if str.to_s.downcase == "true" || str.to_s.downcase == "1" || str.to_s.downcase == "yes"
      true
    elsif str.to_s.downcase == "false" || str.to_s.downcase == "0" || str.to_s.downcase == "no" || str == nil 
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

  def user_type(remote, user = nil)
    if user
      if remote.member_list.members.include? user.id
        return 'member'
      elsif remote.user
        return 'owner' if remote.user.id == user.id
        return 'user'
      else
        return 'user'
      end
    else
      return 'guest'
    end
  end

  def sanitized_name(user)
    user_name = user.name.split(' ')
    return user_name.join('+')
  end

  def remote_authorization_checkbox(remote, kind, permission)
    if remote.authorization[kind][permission] == "1"
      check_box_tag "#{kind}[#{permission}]", 1, "active"
    elsif remote.authorization[kind][permission] == "0"
      check_box_tag "#{kind}[#{permission}]", 1
    end
  end

  def return_user(member)
    User.find(member)
  end
end
