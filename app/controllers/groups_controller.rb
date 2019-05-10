class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :leave, :affiliation, :affiliate]
  before_action :set_commoner, only: [:new, :create, :leave, :join_and_associate_qr_wallet]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group_stories = @group.stories.published
    # All the stories published by group's members:
    # @group_stories = Story.where(commoner: @group.members).published
    @story_types_and_lists = {
      commoners_voice: @group_stories.commoners_voice.first(6),
      good_practice: @group_stories.good_practice.first(6),
      welfare_provision: @group_stories.welfare_provision.first(6)
    }
    @members = @group.memberships.order(created_at: :desc).limit(10).map(&:commoner)

    @pending_join_requests = JoinRequest.where(group: @group).pending.includes(:commoner)
    @new_join_request = @group.join_requests.build

    @discussions = Discussion.where(group: @group).includes(:messages).order(updated_at: :desc)
    @new_discussion = @group.discussions.build
    @currency = @group.currency || @group.build_currency
    @group_wallet = @group.wallet
    # here @wallet is the commoner's wallet in group currency
    @wallet = Wallet.find_by(currency: @group.currency, walletable: current_user.meta) if user_signed_in? && @group.currency.persisted?
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

  def leave
    @membership = Membership.find_by(group: @group, commoner: @commoner)
  end

  def affiliation
    @commoner = Commoner.find_by name: params[:commoner_name]
    raise CanCan::AccessDenied.new unless can_affiliate_commoner?(@commoner)
  end

  def affiliate
    @commoner = Commoner.find_by id: commoner_params[:id]
    raise CanCan::AccessDenied.new unless can_affiliate_commoner?(@commoner)
    @commoner.name = commoner_params[:name]
    # New values are assigned to the user (and later saved)
    # to avoid assigning also the id, which causes problems
    user = @commoner.user
    user.email = commoner_params[:user_attributes][:email]
    user.password = commoner_params[:user_attributes][:password]
    respond_to do |format|
      if @commoner.valid? # this validates also the user
        user.save
        @commoner.save
        membership = Membership.find_by group: @group, commoner: @commoner
        if membership.role.nil?
          membership.role = 'affiliate'
          membership.save
        end
        sign_in(user, scope: :user)
        format.html { redirect_to commoner_path(@commoner), notice: _('Activation complete!') }
      else
        format.html { render :affiliation }
      end
    end
  end

  def join_and_associate_qr_wallet
    if params[:hash_id].present?
      wallet = Wallet.find_by(hash_id: params[:hash_id])
      respond_to do |format|
        if wallet.present? && !@commoner.member_of?(wallet.currency.group)
          associate_commoner_to_wallet(@commoner, wallet)
          format.html { redirect_to wallet_short_path(wallet.hash_id), notice: _('Good! This wallet has been associated to your account') }
        else
          format.html { redirect_to wallet_short_path(wallet.hash_id), alert: _('Oh no, an error occurred') }
        end
      end
    end
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = @commoner.groups.build(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: _('Group was successfully created.') }
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
        format.html { redirect_to @group, notice: _('Group was successfully updated.') }
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

    # These are used for group affiliation
    def commoner_params
      params.require(:commoner).permit(:id, :name, user_attributes: [:email, :password])
    end

    def clear_session_after_signup
      session.delete :create_group
    end

    def can_affiliate_commoner?(commoner)
      !user_signed_in? &&
      @group.members.include?(commoner) &&
      !(@group.affiliates.include?(commoner) ||
      @group.editors.include?(commoner) ||
      @group.admins.include?(commoner))
    end
end
