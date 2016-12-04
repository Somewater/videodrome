require 'json'

class FFMpegAdapter
  class << self
    # return size (bytes), duration (sec), width, height
    def ffprobe(filepath)
      out = `ffprobe -v quiet -print_format json -show_format -show_streams #{filepath}`
      out = JSON.parse(out)
      format = out['format']
      stream = out['streams'].find{|s| s['codec_type'] == 'video' }
      [format['size'].to_i, format['duration'].to_f, stream['coded_width'].to_i, stream['coded_height'].to_i]
    end

    # create preview
    def preview(video_file, output_image, time_sec)
      _, max_time_sec, _, _ = ffprobe(video_file)
      time = Time.at([(max_time_sec / 2.0).to_i, time_sec.to_i].min).utc.strftime("%H:%M:%S")
      status = system "ffmpeg -ss #{time} -i #{video_file} -vframes 1 -q:v 2 #{output_image} > /dev/null 2>&1"
      puts "Preview for #{video_file} created with status: #{status}"
    end
  end
end