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
end
