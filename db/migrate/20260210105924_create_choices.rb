class CreateChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :choices do |t|
      t.references :poll, null: false, foreign_key: true, index: true
      t.string :text, null: false, limit: 200
      t.integer :position, default: 0, null: false
      t.integer :votes_count, default: 0, null: false

      t.timestamps
    end

    add_index :choices, [:poll_id, :position]
  end
end
