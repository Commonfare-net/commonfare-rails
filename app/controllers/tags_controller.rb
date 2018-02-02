class TagsController < ApplicationController
  # load and authorize are separate to make FriendlyID work
  # with both :id and :slug
  authorize_resource # managed by CanCanCan
  def show
    @tag = Tag.friendly.find params[:id]
    @stories = @tag.stories
  end
end
