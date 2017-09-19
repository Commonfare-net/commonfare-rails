class TagsController < ApplicationController
  load_and_authorize_resource
  def show
    @stories = @tag.stories
  end
end
