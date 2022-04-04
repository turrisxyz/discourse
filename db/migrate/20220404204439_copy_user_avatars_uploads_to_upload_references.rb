# frozen_string_literal: true

class CopyUserAvatarsUploadsToUploadReferences < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT custom_upload_id, 'Category', id
      FROM user_avatars
      WHERE custom_upload_id IS NOT NULL
    SQL

    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT gravatar_upload_id, 'Category', id
      FROM user_avatars
      WHERE gravatar_upload_id IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
