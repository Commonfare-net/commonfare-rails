class StoriesController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :story, through: :commoner, shallow: true
  before_action :set_story_locale#, only: [:new, :edit, :create, :update]

  # GET /stories
  # GET /stories.json
  def index
    @stories = @commoner.stories
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
  end

  # GET /stories/new
  def new
    @story = @commoner.stories.build
  end

  # GET /stories/1/edit
  def edit
    # binding.pry
  end

  # POST /stories
  # POST /stories.json
  def create
    # NOTE: To avoid DEPRECATION WARNING when saving with Globalize attributes
    # wait for this pull request to be merged https://github.com/globalize/globalize/pull/629
    # binding.pry
    # Temporary change I18n.locale for saving the Story using @story_locale
    current_locale = I18n.locale
    I18n.locale = @story_locale
    @story = @commoner.stories.build(story_params)
    respond_to do |format|
      if @story.save
        # I18n.locale back to the original
        I18n.locale = current_locale
        format.html { redirect_to story_path(@story, story_locale: @story_locale), notice: _('Story was successfully created.') }
        format.json { render :show, status: :created, location: @story }
      else
        # I18n.locale back to the original
        I18n.locale = current_locale
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    respond_to do |format|
      # NOTE: To avoid DEPRECATION WARNING when saving with Globalize attributes
      # wait for this pull request to be merged https://github.com/globalize/globalize/pull/629

      # Temporary change I18n.locale for saving the Story using @story_locale
      current_locale = I18n.locale
      I18n.locale = @story_locale
      if @story.update(story_params)
        # I18n.locale back to the original
        I18n.locale = current_locale
        format.html { redirect_to story_path(@story, story_locale: @story_locale), notice: _('Story was successfully updated.') }
        format.json { render :show, status: :ok, location: @story }
      else
        # I18n.locale back to the original
        I18n.locale = current_locale
        format.html { render :edit }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story.destroy
    respond_to do |format|
      format.html { redirect_to stories_url, notice: _('Story was successfully destroyed.') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_story_locale
      @story_locale = I18n.locale
      if params[:story_locale].present? && I18n.available_locales.include?(params[:story_locale].to_sym)
        @story_locale = params[:story_locale].to_sym
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def story_params
      params.require(:story).permit(:title, :content, :place, tag_ids: [])
    end
end
