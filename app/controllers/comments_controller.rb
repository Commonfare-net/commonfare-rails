class CommentsController < ApplicationController
  # before_action :set_comment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # skip_authorize_resource only: :create
  # skip_authorization_check only: :create
  before_action :load_commentable, only: :create
  before_action :set_commoner, only: [:create, :edit, :update]
  before_action :set_story_locale

  # GET /comments
  # GET /comments.json
  def index
    if params[:story_id].present?
      @story = Story.friendly.find(params[:story_id])
      @comments = @story.comments
    elsif params[:listing_id].present?
      @listing = Listing.friendly.find(params[:listing_id])
      @comments = @listing.comments
    elsif params[:commoner_id].present?
      @commoner = Commoner.find(params[:commoner_id])
      if current_user == @commoner.user
        @comments = @commoner.comments.order('created_at DESC')
      else
        @comments = @commoner.comments.where(anonymous: false).order('created_at DESC')
      end

    else
      @comments = []
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.commoner = @commoner

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @commentable, notice: _('Comment was successfully created.') }
        format.json { render :show, status: :created, location: @comment }
      else
        # Here I show the story again, so I need to set the instance variables
        @story = @commentable
        @comments = @story.comments - [@comment]
        format.html { render 'stories/show'  }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment.commentable, notice: _('Comment was successfully updated.') }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @commentable = @comment.commentable
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @commentable, notice: _('Comment was successfully destroyed.') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_commoner
      @commoner = current_user.meta
    end

    def load_commentable
      resource, id = request.path.split('/')[2,2]
      @commentable = resource.singularize.classify.constantize.friendly.find(id)
    end

    # This is the same as the one in StoriesController, but it is not an optimal solutions
    # as here the story#show is rendered in case of validation errors, so basically
    # the story_locale is not passed through the various controllers' actions
    def set_story_locale
      @story_locale = I18n.locale
      if params[:story_locale].present? && I18n.available_locales.include?(params[:story_locale].to_sym)
        @story_locale = params[:story_locale].to_sym
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:body, :anonymous)
    end
end
