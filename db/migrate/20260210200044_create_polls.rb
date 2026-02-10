class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.text :question, null: false
      t.datetime :deadline, null: false

      t.timestamps
    end

    add_index :polls, :created_at
    add_index :polls, :deadline
  end
end
