class Comment < ApplicationRecord
  include Authorable
  acts_as_notifiable :commoners,
    # Set to notify to the counterpart of the conversation
    # NOTE: the lambda must return an array!
    targets: ->(comment, key) {
      (comment.commentable.comments.map(&:author) +
      [comment.commentable.commoner] -
      [comment.author]).uniq
    },
    notifier: :commoner,
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :comment_target_path
  belongs_to :commentable, polymorphic: true

  before_destroy :destroy_notifications

  validates :body, presence: true

  private

  def comment_target_path
    return listing_path(self.commentable, locale: I18n.locale) if self.commentable.is_a? Listing
    story_path(self.commentable, locale: I18n.locale, anchor: "comment-#{self.id}")
  end

  def destroy_notifications
    ActivityNotification::Notification.where(notifiable: self).destroy_all
  end
end
