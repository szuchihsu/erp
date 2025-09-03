class CreateDesignImages < ActiveRecord::Migration[8.0]
  def change
    create_table :design_images do |t|
      t.references :design_request, null: false, foreign_key: true
      t.string :image_path
      t.string :image_type
      t.text :description
      t.boolean :is_final

      t.timestamps
    end
  end
end
