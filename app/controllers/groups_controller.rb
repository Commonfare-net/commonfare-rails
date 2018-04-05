class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :set_commoner, only: [:new, :create]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    # TODO: group_stories will be those published as the group
    @group_stories = Story.where(commoner: @group.members).published
    @story_types_and_lists = {
      commoners_voice: @group_stories.commoners_voice.order('created_at DESC').first(6),
      good_practice: @group_stories.good_practice.order('created_at DESC').first(6),
      welfare_provision: @group_stories.welfare_provision.order('created_at DESC').first(6)
    }
    @members = @group.members

    @pending_join_requests = JoinRequest.where(group: @group).pending
    @new_join_request = @group.join_requests.build

    @discussions = Discussion.where(group: @group)
    @new_discussion = @group.discussions.build
  end

  # GET /groups/new
  def new
    clear_session_after_signup
    @new_group_after_signup = params['new_group_after_signup'] == 'true'
    @group = @commoner.groups.build
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = @commoner.groups.build(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    def set_commoner
      @commoner = current_user.meta
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :description, :avatar)
    end

    def clear_session_after_signup
      session.delete :create_group
    end
end
