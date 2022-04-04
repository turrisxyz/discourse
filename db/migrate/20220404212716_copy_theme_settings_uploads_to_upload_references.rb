# frozen_string_literal: true

class CopyThemeSettingsUploadsToUploadReferences < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO upload_references(upload_id, target_type, target_id)
      SELECT value::int, 'ThemeSetting', id
      FROM theme_settings
      WHERE data_type = 6 AND value IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
