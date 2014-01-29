class RemotesController < ApplicationController
	def new
		@remote = Remote.new
	end

	def create
		begin
			video_info = VideoInfo.new(params[:video_url])
			remote = Remote.create!({
				video_id: video_info.video_id,
				provider: video_info.provider,
				title: video_info.title,
				description: video_info.description,
				duration: video_info.duration,
				thumbnail_small: video_info.thumbnail_small,
				thumbnail_medium: video_info.thumbnail_medium,
				thumbnail_large: video_info.thumbnail_large,
				embed_url: video_info.embed_url,
				embed_code: video_info.embed_code,
				date: video_info.date
			})
		rescue
			redirect_to root_path
			flash[:success] = "Invalid URL"
			return
		end
		redirect_to root_path
		flash[:success] = "Congratulations!"
	end
end
