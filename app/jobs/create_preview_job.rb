require 'ffmpeg_adapter'

class CreatePreviewJob < ApplicationJob
  def perform(video_id)
    video = Video.find(video_id)
    video.preview_path = video.assets_directory.join('preview.jpg')
    FileUtils.mkdir_p(File.dirname(video.preview_path))
    FFMpegAdapter.preview(video.original_filepath, video.preview_path, 5)
    video.save
  end
end