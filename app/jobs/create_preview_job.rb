class CreatePreviewJob < ApplicationJob
  def perform(video_id)
    # TODO
    video = Video.find(video_id)

    video.preview_path = video.assets_directory.join('preview.jpg')
    FileUtils.mkdir_p(File.dirname(video.preview_path))
    FileUtils.cp(Rails.public_path.join('rails.png'), video.preview_path)
    video.save
  end
end