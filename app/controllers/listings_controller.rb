class ListingsController < ApplicationController
  # This must stay **before** cancan methods, because they do a Listing.new(listing_params)
  # but new tags break it
  before_action :create_new_tags, only: [:create, :update]

  # load and authorize are separate to make FriendlyID work
  # with both :id and :slug
  before_action :set_listing, except: [:new, :create, :index, :commonplace] # manual load
  authorize_resource :listing # managed by CanCanCan

  before_action :set_commoner, except: [:index, :show]

  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.order(created_at: :desc).includes(:commoner, :tags, :comments, :images)
  end

  def commonplace
    @listings = Listing.order(created_at: :desc).includes(:commoner, :tags, :comments, :images)
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    @images = @listing.images.order(created_at: :asc)
    @comments = @listing.comments
    if user_signed_in?
      @comment = current_user.meta.comments.build
    end
  end

  # GET /listings/new
  def new
    @listing = @commoner.listings.build
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = @commoner.listings.build(listing_params)
    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:title, :description, :place, :min_price, :max_price, tag_ids: [], images_attributes: [:id, :commoner_id, :picture, :imageable_id, :imageable_type, :picture_cache, :_destroy]).tap do |lp|
        if lp[:images_attributes].present?
          lp.merge images_attributes: lp[:images_attributes].transform_values! {|v| v.merge(commoner_id: current_user.meta.id)}
        end
      end
    end

    def set_commoner
      @commoner = params[:commoner_id].present? ? params[:commoner_id] : current_user.meta
    end

    # This method creates the not-yet-existing tags and replaces
    # tag_ids with their ids.
    def create_new_tags
      if params[:listing][:tag_ids].present?
        params[:listing][:tag_ids].map! do |tag_id|
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
