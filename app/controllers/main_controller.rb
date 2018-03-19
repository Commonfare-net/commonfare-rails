class MainController < ApplicationController

  def autocomplete
    @stories = Story.with_translations(I18n.locale).ransack(
      translations_title_cont: params[:q]
    ).result(distinct: true).limit(5)
    @tags = Tag.ransack(
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
    results = Story.published.with_translations(I18n.locale).ransack(
      translations_title_or_translations_content_or_tags_name_or_place_cont: @q
    ).result(distinct: true)

    @story_types_and_lists = {
      commoners_voice: results.commoners_voice.order('created_at DESC'),
      good_practice: results.good_practice.order('created_at DESC'),
      welfare_provision: results.welfare_provision.order('created_at DESC')
    }

    @tags = Tag.ransack(
      name_cont: @q
    ).result(distinct: true)
  end
end
