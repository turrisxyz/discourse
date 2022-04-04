# frozen_string_literal: true

class CopyUsersUploadsToUploadReferences < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT uploaded_avatar_id, 'User', id
      FROM users
      WHERE uploaded_avatar_id IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
