class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.string :question, null: false, limit: 500
      t.datetime :deadline, null: false
      t.string :access_code, null: false, limit: 8
      t.boolean :show_results_while_voting, default: false, null: false
      t.string :status, default: 'active', null: false
      t.integer :total_votes, default: 0, null: false

      t.timestamps
    end

    add_index :polls, :access_code, unique: true
    add_index :polls, :status
    add_index :polls, :deadline
  end
end
