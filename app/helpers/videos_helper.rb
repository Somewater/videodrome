module VideosHelper
  def filepath_url filepath
    filepath.to_s.sub(Rails.public_path.to_s, '')
  end
end
