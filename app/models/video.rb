class Video < ApplicationRecord
  enum status: { inited: 0, uploaded: 1, previewed: 2, encoded: 3 }

  before_save :check_watermark

  validates :title, presence: true
  validates :watermark, presence: true

  protected

  def check_watermark
    if self.watermark_changed?
      case self.status.to_sym
        when :previewed
          EncodinJob.perform_later(self.id)
        when :encoded
          self.previewed!
          EncodinJob.perform_later(self.id)
      end
    end
  end
end
