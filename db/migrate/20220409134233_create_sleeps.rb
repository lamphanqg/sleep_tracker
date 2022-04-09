class CreateSleeps < ActiveRecord::Migration[7.0]
  def change
    create_table :sleeps do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :duration, index: true

      t.timestamps
    end

    add_index :sleeps, :created_at
  end
end
