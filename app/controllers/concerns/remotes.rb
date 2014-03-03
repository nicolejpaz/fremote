module Remotes
  def self.what_to_render(user = nil, guest_name = nil)
    unless user
      "guest" unless guest_name
    else
      "show"
    end
  end
end