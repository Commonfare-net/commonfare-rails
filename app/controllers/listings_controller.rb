class ListingsController < ApplicationController
  # This must stay **before** cancan methods, because they do a Listing.new(listing_params)
  # but new tags break it
  before_action :create_new_tags, only: [:create, :update]

  load_and_authorize_resource
  before_action :set_commoner, only: [:new, :create, :destroy]

  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.all
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
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
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:title, :description, :place, :min_price, :max_price, tag_ids: [])
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
