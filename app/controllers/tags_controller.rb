class TagsController < ApplicationController
  # load and authorize are separate to make FriendlyID work
  # with both :id and :slug
  authorize_resource # managed by CanCanCan
  def show
    @tag = Tag.friendly.find params[:id]
    stories = @tag.stories.accessible_by(current_ability)

    # Welfare provisions are already scoped in the current locale language
    @story_types_and_lists = {
      tutorial: stories
        .tutorial
        .includes(:commoner, :tags, :comments, :images, :translations),
      commoners_voice: stories
        .commoners_voice
        .includes(:commoner, :tags, :comments, :images, :translations),
      good_practice: stories
        .good_practice
        .includes(:commoner, :tags, :comments, :images, :translations),
      welfare_provision: stories
        .welfare_provision
        .includes(:commoner, :tags, :comments, :images)
    }

    @listings = @tag.listings.includes(:commoner, :tags, :comments, :images)
  end
end
