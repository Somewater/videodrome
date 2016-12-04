module VideosHelper
  def filepath_url filepath
    filepath.to_s.sub(Rails.public_path.to_s, '')
  end

  def video_status_color video
    case video.status.to_sym
      when :inited
        'gray'
      when :uploaded
        'darkblue'
      when :previewed
        'blue'
      when :encoded
        'forestgreen'
    end
  end
end
