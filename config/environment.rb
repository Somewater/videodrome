# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.config.video_path = Rails.public_path.join('content', 'video')
FileUtils.mkdir_p(Rails.application.config.video_path)
