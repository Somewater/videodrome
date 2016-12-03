class FileCleanerJob < ApplicationJob
  def perform(filepath)
    FileUtils.rm_rf(filepath)
  end
end