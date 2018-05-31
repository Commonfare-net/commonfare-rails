class Ability
  include CanCan::Ability

  def initialize(user)
    case user
    when AdminUser
      can :manage, :all
    else
      user ||= User.new # guest user (not logged in)
      # visitors can see Commoners, Stories, Tags
      can :read, Commoner
      can :read, Story, published: true
      can :read, Tag
      can :read, Comment
      can :read, Group
      can [:read, :commonplace], Listing
      cannot :read, Wallet, currency_id: nil
      alias_action :create, :read, :update, :destroy, to: :crud
      if user.is_commoner?
        commoner = user.meta
        can :crud, Commoner, id: commoner.id
        can :welcome, Commoner do |commoner|
          commoner.user.sign_in_count == 1
        end
        can :templates, Story
        can :crud, Story, commoner_id: commoner.id
        can [:publish, :preview], Story, commoner_id: commoner.id
        can [:create, :update, :destroy], Comment, commoner_id: commoner.id
        can [:create, :destroy], Image, commoner_id: commoner.id

        can [:update, :destroy], Membership, commoner_id: commoner.id
        can :create, Group
        can [:update, :leave], Group, memberships: {commoner_id: commoner.id}
        can :join, Group do |group|
          !commoner.member_of? group
        end
        can :create, JoinRequest do |join_request|
          # commoner must not be a member and there must be no pending requests
          !commoner.member_of?(join_request.group) &&
          JoinRequest.where(commoner_id: commoner.id, group_id: join_request.group.id, aasm_state: 'pending').empty?
        end
        can [:read, :update], JoinRequest, group_id: commoner.group_ids
        can [:accept, :reject], JoinRequest, group_id: commoner.group_ids, aasm_state: 'pending'
        can :read, JoinRequest, commoner_id: commoner.id

        can [:read, :create], Discussion, group_id: commoner.group_ids
        can :create, Message do |message|
          if message.messageable.respond_to?(:group)
            commoner.groups.include? message.messageable.group
          else
            # TODO: condition for conversations
            message.conversation.sender.id == commoner.id ||
            message.conversation.recipient.id == commoner.id
          end
        end
        can :destroy, Message, commoner_id: commoner.id
        can :read, Wallet, walletable_id: commoner.id, walletable_type: commoner.class.name
        can :autocomplete, Wallet

        if ENV['WALLET_ENABLED'] == 'true' && commoner.wallet.present?
          can :read, Transaction, from_wallet_id: commoner.wallet.id
          can :read, Transaction, to_wallet_id: commoner.wallet.id
          can [:create, :confirm], Transaction, from_wallet_id: commoner.wallet.id
        end

        can :create, Conversation
        can :read, Conversation, sender_id: commoner.id
        can :read, Conversation, recipient_id: commoner.id

        can [:create, :update, :destroy], Listing, commoner_id: commoner.id

        # Group Currency
        can :create, Currency do |currency|
          currency.group.admins.include?(commoner) &&
          !currency.persisted?
        end
        can :update, Currency do |currency|
          currency.group.admins.include?(commoner)
        end
        # Group Wallet
        can :read, Wallet do |wallet|
          wallet.currency.present? &&
          wallet.currency.group.admins.include?(commoner)
        end
      end
    end
  end
end
