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
      alias_action :create, :read, :update, :destroy, :to => :crud
      if user.is_commoner?
        commoner = user.meta
        can :crud, Commoner, id: commoner.id
        can :welcome, Commoner do |commoner|
          commoner.user.sign_in_count == 1
        end
        can :crud, Story, commoner_id: commoner.id
        can [:publish, :preview], Story, commoner_id: commoner.id
        can [:create, :update, :destroy], Comment, commoner_id: commoner.id
        can [:create, :destroy], Image, commoner_id: commoner.id

        can :read, Wallet, commoner_id: commoner.id
        
        can :read, Transaction, from_wallet_id: commoner.wallet.id
        can :read, Transaction, to_wallet_id: commoner.wallet.id
        can :create, Transaction, from_wallet_id: commoner.wallet.id
      end
    end
  end
end
