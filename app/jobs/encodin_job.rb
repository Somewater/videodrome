class EncodinJob < ApplicationJob
  def perform(video_id)
    # TODO
    video = Video.find(video_id)

    i = 1
    new_name = lambda {
      File.join(File.dirname(video.original_filepath),
                "encoded" + (i > 1 ? "_#{i}" : '') + File.extname(video.original_filepath))
    }

    video.encoded_filepath = new_name.call()
    while video.encoded_filepath == video.original_filepath
      i += 1
      video.encoded_filepath = new_name.call()
    end

    FileUtils.mkdir_p(File.dirname(video.encoded_filepath))
    FileUtils.cp(video.original_filepath, video.encoded_filepath)
    video.save
  end
end