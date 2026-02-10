class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :poll, null: false, foreign_key: true, index: true
      t.string :text, null: false, limit: 255
      t.integer :position, null: false

      t.timestamps
    end

    add_index :answers, [ :poll_id, :position ], unique: true
  end
end
