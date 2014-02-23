module Chat
	def self.guest_display_name(user = nil)
		return user.name if user
		return $funny_names["names"][rand($funny_names["names"].length - 1)] + $funny_names["surnames"][rand($funny_names["surnames"].length - 1)] + rand(99).to_s
	end
end