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
      @story_types_and_lists = {
        commoners_voice: Story.commoners_voice.order('created_at DESC').first(6),
        good_practice: Story.good_practice.order('created_at DESC').first(6),
        welfare_provision: Story.welfare_provision.order('created_at DESC').first(6)
      }
    end
  end
end
