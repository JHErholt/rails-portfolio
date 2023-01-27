class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :thumbnail_url
      t.text :thumbnail_alt
      t.integer :featured
      t.string :link_to_page
      t.string :link_to_github
      t.json :content

      t.timestamps
    end
  end
end
