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
      can :read, Story
      can :read, Tag
      can :read, Comment
      can :read, Group
      alias_action :create, :read, :update, :destroy, :to => :crud
      if user.is_commoner?
        commoner = user.meta
        can :crud, Commoner, id: commoner.id
        can :welcome, Commoner do |commoner|
          commoner.user.sign_in_count == 1
        end
        can [:create, :update, :destroy], Story, commoner_id: commoner.id
        can [:create, :update, :destroy], Comment, commoner_id: commoner.id
        can [:create, :destroy], Image, commoner_id: commoner.id

        can [:update, :destroy], Membership, commoner_id: commoner.id
        can :create, Group
        can :update, Group, memberships: {commoner_id: commoner.id}
        can :join, Group do |group|
          !commoner.member_of? group
        end
        can :create, JoinRequest do |join_request|
          !commoner.member_of? join_request.group
        end
        can [:read, :update], JoinRequest, group_id: commoner.group_ids
        can [:accept, :reject], JoinRequest, group_id: commoner.group_ids, aasm_state: 'pending'
        can :read, JoinRequest, commoner_id: commoner.id
      end
    end
  end
end
