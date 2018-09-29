class AddGasProvidedInHexToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :gas_provided_in_hex, :string
  end
end
