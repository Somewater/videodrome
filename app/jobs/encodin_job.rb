require 'ffmpeg_adapter'

class EncodinJob < ApplicationJob

  ENCODING_EXTENSIONS = ['.mp4', '.webm', '.ogv']

  def perform(video_id)
    video = Video.find(video_id)

    orig_filesize, duration, orig_width, orig_height = FFMpegAdapter.ffprobe(video.original_filepath)
    video.duration = duration
    video.filesize = orig_filesize

    encoded_filepath = find_next_encoded_filepath(video.original_filepath)

    FileUtils.mkdir_p(File.dirname(encoded_filepath))
    video.encoded_filepath = encode(video.original_filepath, encoded_filepath).join(',')
    video.save
  end

  def encode(from, to)
    # TODO: add watermark

    logfile = "#{to}.log"
    cmd = "#{Rails.root.join('bin', 'encode2.sh')} #{from} #{to} >> #{logfile} 2>&1"
    File.open("logfile", 'a'){|f| f.write("Start encoding at #{Time.new}\nCOMMAND: #{cmd}\n\n") }
    status = system(cmd)
    File.open("logfile", 'a'){|f| f.write("\n\nComplete encoding at #{Time.new}. Status: #{status}") }
    Dir["#{to}*"].to_a.select{|fp| File.extname(fp) != '.log' }.sort_by{|fp| ENCODING_EXTENSIONS.index(File.extname(fp)) }
  end

  # return filepath w/o extension (like a "/app/content/video.avi" -> "/app/content/encoded")
  def find_next_encoded_filepath(original_filepath)
    i = 1
    new_name = lambda {
      File.join(File.dirname(original_filepath),
                "encoded" + (i > 1 ? "_#{i}" : ''))
    }

    encoded_filepath = new_name.call()
    while encoded_filepath == original_filepath ||
        ENCODING_EXTENSIONS.any?{|ext| File.exist?(encoded_filepath + ext) }
      i += 1
      encoded_filepath = new_name.call()
    end
    encoded_filepath
  end
end