class CurrenciesController < ApplicationController

  load_and_authorize_resource :group
  load_and_authorize_resource :currency, through: :group, singleton: true

  def show
  end

  def edit
  end

  def new
  end

  def create
    @currency = @group.build_currency(currency_params)

    respond_to do |format|
      if @currency.save
        format.html { redirect_to @group, notice: _('Currency was successfully created.') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @currency.update(currency_params)
        format.html { redirect_to @group, notice: _('Currency was successfully updated.') }
      else
        format.html { render :new }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def currency_params
    params.require(:currency).permit(:name, :code, :endpoint)
  end
end
