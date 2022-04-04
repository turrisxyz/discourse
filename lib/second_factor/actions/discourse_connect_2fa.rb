# frozen_string_literal: true

module SecondFactor::Actions
  class DiscourseConnect2fa < Base
    def skip_second_factor_auth?(params)
      !sso.require_2fa
    end

    def second_factor_auth_skipped!(params)
      populate_user_data
    end

    def no_second_factors_enabled!(params)
    end

    def second_factor_auth_required!(params)
    end

    def second_factor_auth_completed!(callback_params)
    end

    private

    def populate_user_data
      sso.name = current_user.name
      sso.username = current_user.username
      sso.email = current_user.email
      sso.external_id = current_user.id.to_s
      sso.admin = current_user.admin?
      sso.moderator = current_user.moderator?
      sso.groups = current_user.groups.pluck(:name).join(",")

      if current_user.uploaded_avatar.present?
        base_url = Discourse.store.external? ? "#{Discourse.store.absolute_base_url}/" : Discourse.base_url
        avatar_url = "#{base_url}#{Discourse.store.get_path_for_upload(current_user.uploaded_avatar)}"
        sso.avatar_url = UrlHelper.absolute Discourse.store.cdn_url(avatar_url)
      end

      if current_user.user_profile.profile_background_upload.present?
        sso.profile_background_url = UrlHelper.absolute(GlobalPath.upload_cdn_path(
          current_user.user_profile.profile_background_upload.url
        ))
      end

      if current_user.user_profile.card_background_upload.present?
        sso.card_background_url = UrlHelper.absolute(GlobalPath.upload_cdn_path(
          current_user.user_profile.card_background_upload.url
        ))
      end
    end

    def sso
      @data[:sso]
    end
  end
end
