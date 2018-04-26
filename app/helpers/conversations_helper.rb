module ConversationsHelper

  def counterpart_for_conversation(conversation)
    conversation.sender == current_user.meta ? conversation.recipient : conversation.sender
  end

  def conversation_with(commoner)
    Conversation.between(current_user.meta, commoner).first
  end
end
