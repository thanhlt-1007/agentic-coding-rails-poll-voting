class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :poll, null: false, foreign_key: true, index: true
      t.references :choice, null: false, foreign_key: true, index: true
      t.string :participant_fingerprint, null: false, limit: 64
      t.string :ip_hash, null: false, limit: 64
      t.string :session_token, limit: 64
      t.datetime :voted_at, null: false

      t.timestamps
    end

    add_index :votes, [:poll_id, :participant_fingerprint], unique: true, name: 'index_votes_on_poll_and_participant'
    add_index :votes, :voted_at
    add_index :votes, :ip_hash
  end
end
