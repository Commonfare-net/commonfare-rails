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
      @featured_stories = Story.last(10)
    end
  end
end
