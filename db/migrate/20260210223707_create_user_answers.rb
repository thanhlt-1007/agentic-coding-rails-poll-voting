class CreateUserAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :user_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :poll, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_answers, [ :user_id, :poll_id ], unique: true
  end
end
