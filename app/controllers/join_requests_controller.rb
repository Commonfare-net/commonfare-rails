class JoinRequestsController < ApplicationController
  before_action :set_join_request, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource :group, only: [:new, :create]
  load_resource through: :group, only: [:new, :create]
  authorize_resource


  # GET /join_requests
  # GET /join_requests.json
  def index
    @join_requests = JoinRequest.all
  end

  # GET /join_requests/1
  # GET /join_requests/1.json
  def show
  end

  # GET /join_requests/new
  def new
    @join_request = @group.join_requests.build(commoner: current_user.meta)
  end

  # GET /join_requests/1/edit
  def edit
  end

  # POST /join_requests
  # POST /join_requests.json
  def create
    @join_request = JoinRequest.new(join_request_params)

    respond_to do |format|
      if @join_request.save
        format.html { redirect_to @join_request, notice: 'Join request was successfully created.' }
        format.json { render :show, status: :created, location: @join_request }
      else
        format.html { render :new }
        format.json { render json: @join_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /join_requests/1
  # PATCH/PUT /join_requests/1.json
  def update
    respond_to do |format|
      if @join_request.update(join_request_params)
        format.html { redirect_to @join_request, notice: 'Join request was successfully updated.' }
        format.json { render :show, status: :ok, location: @join_request }
      else
        format.html { render :edit }
        format.json { render json: @join_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /join_requests/1
  # DELETE /join_requests/1.json
  def destroy
    @join_request.destroy
    respond_to do |format|
      format.html { redirect_to join_requests_url, notice: 'Join request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_join_request
      @join_request = JoinRequest.find(params[:id])
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def join_request_params
      params.require(:join_request).permit(:group_id, :commoner_id)
    end
end
