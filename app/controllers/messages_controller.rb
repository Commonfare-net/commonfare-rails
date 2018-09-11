class MessagesController < ApplicationController
  # before_action :set_message, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource :discussion
  load_and_authorize_resource :conversation
  # load_and_authorize_resource :message, through: :discussion
  load_and_authorize_resource :message, through: [:discussion, :conversation]

  before_action :set_group

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    # @message = Message.new(message_params)
    # @message is built by CanCanCan
    respond_to do |format|
      if @message.save
        @message.notify(:commoners, group: @message.conversation) if @message.in_conversation?
        format.html { redirect_to success_path, notice: _('Message sent') }
      else
        @new_message = @message
        @messages = Message.where(messageable: messageable)
        format.html { render "#{messageable.class.class_name.downcase.pluralize}/show" }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to success_path, notice: _('Message deleted') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    def set_group
      @group = @discussion.group if @discussion.present?
    end

    def success_path
      return group_discussion_path(@group, @discussion) if @discussion.present?
      conversation_path(@conversation)
    end

    def messageable
      return @discussion if @discussion.present?
      @conversation
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:commoner_id, :body)
    end
end
