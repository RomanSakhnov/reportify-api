# Fix users table for Devise when it was created with password_digest (has_secure_password style).
# Run: rails db:migrate
class FixUsersForDevise < ActiveRecord::Migration[7.1]
  def up
    if column_exists?(:users, :password_digest) && !column_exists?(:users, :encrypted_password)
      add_column :users, :encrypted_password, :string, null: false, default: ''
      remove_column :users, :password_digest
    end

    add_column :users, :reset_password_token, :string, null: true unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime, null: true unless column_exists?(:users,
                                                                                            :reset_password_sent_at)
    add_column :users, :remember_created_at, :datetime, null: true unless column_exists?(:users, :remember_created_at)

    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end

  def down
    # No-op: reversible would require knowing previous state
  end
end
