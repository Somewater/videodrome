require 'sidekiq/api'

class Video < ApplicationRecord
  RECORD_RELATED_JOBS = [EncodinJob, CreatePreviewJob].map(&:to_s)

  enum status: { inited: 0, uploaded: 1, previewed: 2, encoded: 3 }

  before_save :check_watermark,         if: :watermark_changed?
  before_save :check_preview_path,      if: :preview_path_changed?
  before_save :check_original_filepath, if: :original_filepath_changed?
  before_save :check_encoded_filepath,  if: :encoded_filepath_changed?
  after_destroy :clear_files

  validates :title, presence: true
  validates :watermark, presence: true

  def assets_directory
    Rails.configuration.video_path.join(self.id.to_s)
  end

  def each_encoded_filepath_with_type(&block)
    (self.encoded_filepath || '').split(',').each do |filepath|
      filetype = if File.extname(filepath) == '.ogv'
                   'ogg'
                 else
                   File.extname(filepath)[1..-1] end
      yield(filepath, filetype)
    end
  end

  protected

  def check_watermark
    case self.status.to_sym
      when :previewed
        schedule_encoding_job!
      when :encoded
        self.status = :previewed
        schedule_encoding_job!
    end
  end

  def check_preview_path
    self.status = :previewed
    if self.original_filepath
      schedule_encoding_job!
    end
  end

  def check_original_filepath
    if self.original_filepath
      CreatePreviewJob.perform_later(self.id)
      self.status = :uploaded
    else
      self.status = :inited
    end
  end

  def check_encoded_filepath
    if self.encoded_filepath
      self.status = :encoded
    else
      self.status = :previewed
    end
  end

  def schedule_encoding_job!
    stop_related_jobs!(EncodinJob.to_s)
    self.encoded_filepath = nil
    EncodinJob.perform_later(self.id)
  end

  def clear_files
    stop_related_jobs!
    FileCleanerJob.perform_later(assets_directory.to_s)
  end

  def stop_related_jobs!(by_class = nil)
    queue = Sidekiq::Queue.new()
    queue.each do |job|
      data = job.args.first
      if (by_class.nil? && RECORD_RELATED_JOBS.include?(data['job_class'])) || data['job_class'] == by_class
        if data['arguments'].first.to_i == self.id
          job.delete
        end
      end
    end
  end
end
