class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    # visitors can see Commoners, Stories, Tags
    can :read, Commoner
    can :read, Story
    can :read, Tag
    alias_action :create, :read, :update, :destroy, :to => :crud
    if user.is_commoner?
      commoner = user.meta
      can :crud, Commoner, id: commoner.id
      can [:create, :update, :destroy], Story, commoner_id: commoner.id
    end
  end
end
