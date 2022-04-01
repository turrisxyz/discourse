# frozen_string_literal: true

class UserBookmarkList
  include ActiveModel::Serialization

  PER_PAGE = 20

  attr_reader :bookmarks, :per_page, :posts, :topics, :chat_messages
  attr_accessor :more_bookmarks_url

  def initialize(user:, guardian:, params:)
    @user = user
    @guardian = guardian
    @params = params

    @params.merge!(per_page: PER_PAGE) if params[:per_page].blank?
    @params[:per_page] = PER_PAGE if @params[:per_page] > PER_PAGE

    @bookmarks = []
  end

  def load
    @bookmarks = BookmarkQuery.new(user: @user, guardian: @guardian, params: @params).list_all
    preload_polymorphic_associations
    @bookmarks
  end

  def per_page
    @per_page ||= @params[:per_page]
  end

  private

  # we have already confirmed the user has access to these records at
  # this point in BookmarkQuery, so it is safe to load them directly
  def preload_polymorphic_associations
    @topics = Topic.includes(:topic_users).where(
      id: Bookmark.select_type(@bookmarks, "Topic").map(&:bookmarkable_id)
    ).where(topic_users: { user_id: @user.id })

    @posts = Post.includes(topic: :topic_users).where(
      id: Bookmark.select_type(@bookmarks, "Post").map(&:bookmarkable_id)
    ).where(topic_users: { user_id: @user.id })

    Bookmark.registered_bookmarkables.each do |registered_bookmarkable|
      bookmarkable_ids = Bookmark.select_type(@bookmarks, registered_bookmarkable.model.name).map(&:bookmarkable_id)
      instance_variable_set(
        :"@#{registered_bookmarkable.model.table_name}",
        registered_bookmarkable.preload_associations(bookmarkable_ids)
      )
    end
  end
end
