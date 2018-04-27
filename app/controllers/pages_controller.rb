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
        commoners_voice: Story.published.commoners_voice.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations).first(6),
        good_practice: Story.published.good_practice.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations).first(6),
        welfare_provision: Story.published.welfare_provision.order('created_at DESC').includes(:commoner, :tags, :comments, :images, :translations).first(6)
      }
    end
  end
end
