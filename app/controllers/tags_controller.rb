class TagsController < ApplicationController
  # load and authorize are separate to make FriendlyID work
  # with both :id and :slug
  authorize_resource # managed by CanCanCan
  def show
    @tag = Tag.friendly.find params[:id]
    stories = @tag.stories.accessible_by(current_ability)

    @story_types_and_lists = {
      commoners_voice: stories.commoners_voice.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations),
      good_practice: stories.good_practice.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations),
      welfare_provision: stories.welfare_provision.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations)
    }
  end
end
