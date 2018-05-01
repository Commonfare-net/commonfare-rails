class ConversationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_sender_and_recipient, except: :index
  before_action :set_commoner, only: [:index, :show]
  after_action :mark_as_read, only: :show

  def index
    @conversations = @commoner.conversations.includes(:messages)
  end

  def show
    @messages = Message.where(messageable: @conversation).order(created_at: 'asc')
    @new_message = @conversation.messages.build(commoner: current_user.meta)
  end

  def new
    @conversation = Conversation.new(sender: @sender, recipient: @recipient)
    @listing = Listing.find_by(id: params[:listing_id]) if params[:listing_id].present?
    @group = Group.find_by(id: params[:group_id]) if params[:group_id].present?
    @conversation.messages.build(commoner: @sender, body: first_message)
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
    params.require(:conversation).permit(:sender_id, :recipient_id, messages_attributes: [:commoner_id, :body])
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

  def mark_as_read
    @messages.where(read: false).find_each do |message|
      if current_user.meta != message.author
        message.read = true
        message.save
      end
    end
  end

  def first_message
    if @listing.present?
      (s_('Conversation|Hello %{recipient_name}, I am intersted in %{listing_title} ( %{listing_url} ) ') %{recipient_name: @recipient.name, listing_title: @listing.title, listing_url: listing_url(@listing)})
    elsif @group.present?
      (s_('Conversation|Hello, would you like to join the group %{group_name} ( %{group_url} )? ') %{group_name: @group.name, group_url: group_url(@group)})
    else
      (s_('Conversation|Hello, '))
    end
  end
end
