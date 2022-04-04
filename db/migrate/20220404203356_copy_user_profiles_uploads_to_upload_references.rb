# frozen_string_literal: true

class CopyUserProfilesUploadsToUploadReferences < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT profile_background_upload_id, 'UserProfile', user_id
      FROM user_profiles
      WHERE profile_background_upload_id IS NOT NULL
    SQL

    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT card_background_upload_id, 'UserProfile', user_id
      FROM user_profiles
      WHERE card_background_upload_id IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
