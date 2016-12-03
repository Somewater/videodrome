class OriginalAndEncodedFilepath < ActiveRecord::Migration[5.0]
  def change
    rename_column :videos, :filepath, :original_filepath
    add_column    :videos, :encoded_filepath, :string
  end
end
