class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.integer :status, default: 0
      t.string  :title, null: false
      t.string  :watermark, null: false

      t.string  :filepath
      t.float   :duration
      t.integer :filesize

      t.string  :preview_path

      t.timestamps
    end
  end
end
