class ConversationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_sender_and_recipient, except: :index
  before_action :set_commoner, only: [:index, :show]

  def index
    @conversations = @commoner.conversations
  end

  def show
    @messages = Message.where(messageable: @conversation).order(created_at: 'asc')
    @new_message = @conversation.messages.build(commoner: current_user.meta)
  end

  def new
    @conversation = Conversation.new(sender: @sender, recipient: @recipient)
    @conversation.messages.build(commoner: @sender)
  end

  def create
    @conversation = Conversation.new(conversation_params)
    respond_to do |format|
      if @conversation.save
        format.html { redirect_to conversation_path(@conversation) }
        format.json { render :show, status: :created, location: @conversation }
      else
        format.html { render :new }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:sender_id, :recipient_id)
  end

  def set_sender_and_recipient
    @sender = current_user.meta
    # find_by returns nil and not an exception if record doesn't exist
    @recipient = Commoner.find_by(id: params[:recipient_id])
    if @conversation.persisted?
      @sender = @conversation.sender
      @recipient = @conversation.recipient
    end
  end

  def set_commoner
    @commoner = current_user.meta
  end
end
