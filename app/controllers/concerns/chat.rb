module Chat
	def self.guest_display_name(user = nil, guest_name = nil)
		return user.name if user
    return "#{guest_name}_anon#{rand(99).to_s}" if guest_name != ""
    return $funny_names["names"][rand($funny_names["names"].length - 1)] + $funny_names["surnames"][rand($funny_names["surnames"].length - 1)] + "_anon#{rand(99).to_s}"
  end
end