class MainController < ApplicationController

  def autocomplete
    @stories  = Story.ransack(
                        translations_title_cont: params[:q]
                      ).result(distinct: true).limit(5)
    @tags     = Tag.ransack(
                        name_cont: params[:q]
                      ).result(distinct: true).limit(5)
  end

  def search
    # To search only in selected languages text use this
    # @stories  = Story.with_translations(:it)ransack(translations_title_cont: params[:q]).result(distinct: true).limit(5)
    # To search in all languages use this
    @q = params[:q]
    # no search key? Get back to where you once belonged (cit. The Beatles)
    redirect_back(fallback_location: root_path) if @q.blank?
    @stories  = Story.ransack(
                        translations_title_or_translations_content_or_tags_name_cont: @q
                      ).result(distinct: true)
    @tags     = Tag.ransack(
                        name_cont: @q
                      ).result(distinct: true)
  end
end
