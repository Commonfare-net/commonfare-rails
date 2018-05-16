class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action :home
  # before_filter :authenticate
  # layout :layout_for_page

  private

  def layout_for_page
    case params[:id]
    when 'home'
      'home'
    else
      'application'
    end
  end

  def home
    if params[:id] == 'home'
      # Welfare provisions are already scoped in the current locale language
      @story_types_and_lists = {
        commoners_voice: Story.published.commoners_voice
          .includes(:commoner, :tags, :comments, :images, :translations)
          .first(6),
        good_practice: Story.published.good_practice
          .includes(:commoner, :tags, :comments, :images, :translations)
          .first(6),
        welfare_provision: Story.published.welfare_provision
          .includes(:commoner, :tags, :comments, :images)
          .first(6)
      }
    end
  end
end
