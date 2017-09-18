class MainController < ApplicationController
  def search
    # To search only in selected languages text use this
    # @stories  = Story.with_translations(:it)ransack(translations_title_cont: params[:q]).result(distinct: true).limit(5)
    # To search in all languages use this
    @stories  = Story.ransack(translations_title_cont: params[:q]).result(distinct: true)
    @tags     = Tag.ransack(name_cont: params[:q]).result(distinct: true)

    respond_to do |format|
      format.html
      format.json {
        @stories = @stories.limit(5)
        @tags = @tags.limit(5)
      }
    end
  end
end
