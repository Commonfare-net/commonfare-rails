class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    # guests can see a Commoner
    can :read, Commoner
    can :read, Story
    alias_action :create, :read, :update, :destroy, :to => :crud
    # binding.pry
    if user.is_commoner?
      commoner = user.meta
      can :crud, Commoner, id: commoner.id
      can :crud, Story, commoner_id: commoner.id
    end
  end
end
