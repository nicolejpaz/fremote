module RemotesHelper
  def to_boolean(str)
    if str.downcase == "true" || str == "1" || str == 1
      true
    elsif str.downcase == "false" || str == "0" || str == 0
      false
    else
      nil
    end
  end
end
