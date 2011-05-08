class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.datetime :image_creation_date, :null => false

      t.timestamps
    end
    add_index(:images, :image_creation_date)
  end

  def self.down
    drop_table :images
  end
end
