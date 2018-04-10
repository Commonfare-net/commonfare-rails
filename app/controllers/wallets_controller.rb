class WalletsController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :wallet, through: :commoner, singleton: true
  
  def show
  end
end
