class CommonersController < ApplicationController
  # This must stay **before** cancan methods, because they do a Commoner.new(commoner_params)
  # but new tags break it
  before_action :create_new_tags, only: :update

  load_and_authorize_resource
  # before_action :set_commoner, only: [:show, :edit, :update, :destroy]

  def welcome
    # redirect_back(fallback_location: root_path) if @commoner.user.sign_in_count > 1
    @commoner = current_user.meta
  end
  # GET /commoners
  # GET /commoners.json
  def index
    @commoners = Commoner.all
  end

  # GET /commoners/1
  # GET /commoners/1.json
  def show
    if current_user == @commoner.user
      @stories = @commoner.stories
    else
      @stories = @commoner.stories.published.where(anonymous: false, group: nil)
    end
    @story_types_and_lists = {
      commoners_voice: @stories.commoners_voice.order('created_at DESC').first(6),
      good_practice: @stories.good_practice.order('created_at DESC').first(6),
      welfare_provision: @stories.welfare_provision.order('created_at DESC').first(6)
    }
  end

  # GET /commoners/new
  def new
    @commoner = Commoner.new
  end

  # GET /commoners/1/edit
  def edit
  end

  # POST /commoners
  # POST /commoners.json
  def create
    @commoner = Commoner.new(commoner_params)

    respond_to do |format|
      if @commoner.save
        format.html { redirect_to @commoner }
        format.json { render :show, status: :created, location: @commoner }
      else
        format.html { render :new }
        format.json { render json: @commoner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commoners/1
  # PATCH/PUT /commoners/1.json
  def update
    respond_to do |format|
      if @commoner.update(commoner_params)
        format.html { redirect_to @commoner }
        format.json { render :show, status: :ok, location: @commoner }
      else
        format.html { render :edit }
        format.json { render json: @commoner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commoners/1
  # DELETE /commoners/1.json
  def destroy
    @commoner.destroy
    respond_to do |format|
      format.html { redirect_to commoners_url, notice: 'Commoner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commoner
      @commoner = Commoner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commoner_params
      params.require(:commoner).permit(:name, :avatar, :description, tag_ids: [])
    end

    # This method creates the not-yet-existing tags and replaces
    # tag_ids with their ids.
    def create_new_tags
      if params[:commoner][:tag_ids].present?
        params[:commoner][:tag_ids].map! do |tag_id|
          if Tag.exists? tag_id
            tag_id
          else
            new_tag = Tag.create(name: tag_id.downcase)
            new_tag.id
          end
        end
      end
    end
end
