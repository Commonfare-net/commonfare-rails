class AddApiKeyToCurrencies < ActiveRecord::Migration[5.1]
  def change
    add_column :currencies, :api_key, :string
  end
end
