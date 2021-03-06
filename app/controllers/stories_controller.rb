class StoriesController < ApplicationController
  # This must stay **before** cancan methods, because they do a Story.new(story_params)
  # but new tags break it
  before_action :create_new_tags, only: [:create, :update]

  # load and authorize are separate to make FriendlyID work
  # with both :id and :slug
  before_action :set_story, except: [:new, :builder, :create, :index, :templates] # manual load
  authorize_resource :story, except: [:templates] # managed by CanCanCan

  before_action :set_commoner, only: [:new, :builder, :create, :edit, :update]
  before_action :set_story_locale

  # GET /stories
  # GET /stories.json
  def index
    accessible_stories = Story.accessible_by(current_ability)

    if params[:commoner_id].present? && Commoner.exists?(params[:commoner_id])
      @commoner = Commoner.find params[:commoner_id]
      if current_user == @commoner.user
        stories = @commoner.stories
      else
        stories = @commoner.stories.published.where(anonymous: false)
      end
    elsif params[:filter].present?
      @filter = params[:filter]
      if Story::TYPES.include? @filter.to_sym
        stories = accessible_stories.send(@filter.to_sym)
        @title = @filter.to_sym
      else
        stories = accessible_stories.commoners_voice
        @title = :commoners_voice
      end
    else
      stories = accessible_stories # All descending
      @title = :all
    end

    # Welfare provisions are already scoped in the current locale language
    @story_types_and_lists = {
      commoners_voice: stories
        .commoners_voice
        .includes(:commoner, :tags, :comments, :images, :translations),
      tutorial: stories
        .tutorial
        .includes(:commoner, :tags, :comments, :images, :translations),
      good_practice: stories
        .good_practice
        .includes(:commoner, :tags, :comments, :images, :translations),
      welfare_provision: stories
        .welfare_provision
        .includes(:commoner, :tags, :comments, :images)
    }
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @comments = @story.comments.order(created_at: :asc)
    # The page_id is used in the id of the <ul> that contains the recommended stories
    @page_id = Digest::SHA1.hexdigest Time.now.to_s
    if user_signed_in?
      @comment = current_user.meta.comments.build
    else
      @comment = Comment.new(commentable: @story)
    end
  end

  def preview
  end

  def recommend
    ids = []
    @stories = []
    commoner_id = user_signed_in? ? current_user.meta.id : '0'
    conn = Faraday.new ENV['COMMONSHARE_ENDPOINT']
    response = conn.get do |req|
      # req.url "/recommend/1/1"
      req.url "/recommend/#{@story.id}/#{commoner_id}"
    end
    # binding.pry
    ids = response.body.strip.gsub(/[^0-9A-Za-z,]/, '').split(',').map(&:to_i) if response.status == 200
    ids.each {|id| @stories << Story.find(id) if Story.exists?(id)}
  end

  # GET /stories/new
  def new
    @story = params[:template].present? ? Story.build_from_template(params[:template]) : Story.new
    @story.commoner = @commoner

    if params[:story_builder] == 'true'
      @story_builder = true
      @story.created_with_story_builder = true
      render :builder
    else
      render :new
    end
  end

  # def builder
  #   if params[:story_id].present?
  #     @story = Story.find params[:story_id]
  #     authorize! :update, @story
  #   else
  #     @story = @commoner.stories.build(created_with_story_builder: true)
  #   end
  # end

  # GET /stories/1/edit
  def edit
    if @story.created_with_story_builder?
      @story_builder = true
      render :builder
    else
      @story.title = @story.title_draft unless @story.title.present?
      @story.content = @story.content_draft unless @story.content.present?
      @story.place = @story.place_draft unless @story.place.present?
      render :edit
    end
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

    if params[:story_builder] == 'true'
      create_with_story_builder(current_locale)
    else
      create_with_text_content(current_locale)
    end
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    # NOTE: To avoid DEPRECATION WARNING when saving with Globalize attributes
    # wait for this pull request to be merged https://github.com/globalize/globalize/pull/629

    # Temporary change I18n.locale for saving the Story using @story_locale
    current_locale = I18n.locale
    I18n.locale = @story_locale

    if params[:story_builder] == 'true'
      update_with_story_builder(current_locale)
    else
      update_with_text_content(current_locale)
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

  def publish
    # set params without saving (used only for anonymous)
    @story.assign_attributes(publish_params)

    if @story.publish!
      respond_to do |format|
        format.html { redirect_to @story }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_story_path(@story), notice: _('Could not publish this story') }
      end
    end
  end

  def templates
    @templates = Story::TEMPLATES[I18n.locale]
  end

  private

    def set_story
      @story = Story.friendly.find params[:id]
    end

    def set_commoner
      @commoner = current_user.meta
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_story_locale
      @story_locale = I18n.locale
      if params[:story_locale].present? && I18n.available_locales.include?(params[:story_locale].to_sym)
        @story_locale = params[:story_locale].to_sym
      end
    end

    def create_with_story_builder(restore_locale)
      @story.created_with_story_builder = true
      if @story.save
        I18n.locale = restore_locale
        respond_to do |format|
          format.json { render :show, status: :ok }
        end
      else
        I18n.locale = restore_locale
        respond_to do |format|
          format.json { render status: :unprocessable_entity, json: @story.errors }
        end
      end
    end

    def update_with_story_builder(restore_locale)
      if @story.update(story_params)
        # I18n.locale back to the original
        I18n.locale = restore_locale
        respond_to do |format|
          format.json { render :show, status: :ok, location: @story }
        end
      else
        # I18n.locale back to the original
        I18n.locale = restore_locale
        respond_to do |format|
          format.json { render json: @story.errors, status: :unprocessable_entity }
        end
      end
    end

    # creates a story with a text content
    def create_with_text_content(restore_locale)
      if @story.save && @story.publish!
        I18n.locale = restore_locale
        respond_to do |format|
          format.html { redirect_to story_path(@story, story_locale: @story_locale), notice: _('Story was successfully created.') }
        end
      else
        I18n.locale = restore_locale
        respond_to do |format|
          format.html { render :new }
        end
      end
    end

    def update_with_text_content(restore_locale)
      if @story.update(story_params) && @story.publish!
        # I18n.locale back to the original
        I18n.locale = restore_locale
        respond_to do |format|
          format.html { redirect_to story_path(@story, story_locale: @story_locale), notice: _('Story was successfully updated.') }
        end
      else
        # I18n.locale back to the original
        I18n.locale = restore_locale
        respond_to do |format|
          format.html { render :edit }
        end
      end
    end

    # This method creates the not-yet-existing tags and replaces
    # tag_ids with their ids.
    def create_new_tags
      if params[:story][:tag_ids].present?
        params[:story][:tag_ids].map! do |tag_id|
          if Tag.exists? tag_id
            tag_id
          else
            new_tag = Tag.create(name: tag_id.downcase)
            new_tag.id
          end
        end
      end
    end

    # MOVED TO THE MODEL
    # This always returns an array, even if content is nil or ""
    # or if there is an embedded video (with iframe)
    # def images_from_content(story)
    #   content = Nokogiri::HTML(story.content)
    #   ids = content.css('figure').map { |fig_ns| fig_ns.css('img').first['src'].scan(/images\/(\d+)\//).last.first.to_i if fig_ns.css('img').present? }.compact
    #   Image.find(ids)
    # end
    # def images_from_content_json_draft(story)
    #   ids = story.content_json_draft
    #              .select { |item| item['type'] == 'image' }
    #              .map { |item| /images\/(?<id>\d+)/ =~ item['content']; id }
    #   Image.find(ids)
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def story_params
      params.tap { |pars| set_draft_params(pars) }
            .require(:story)
            .permit(:title_draft,
                    :content_draft,
                    :place_draft,
                    :anonymous,
                    :group_id,
                    :published,
                    template_json: [:id, :type, :content, :caption, :url],
                    content_json_draft: [:id, :type, :content, :caption, :url],
                    tag_ids: [])
    end

    # Creates draft params if the client sends title, content or content_json
    def set_draft_params(pars)
      pars[:story][:title_draft] = pars[:story][:title]
      pars[:story][:content_draft] = pars[:story][:content]
      pars[:story][:content_json_draft] = pars[:story][:content_json]
      pars[:story][:place_draft] = pars[:story][:place]
    end

    def publish_params
      params.permit(:anonymous, :group_id)
    end
end
