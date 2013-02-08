class AddTennentIdToModels < ActiveRecord::Migration
  def change
    Spree::Landlord.model_names.each do |model|
      table = model.table_name
      unless column_exists?(table.to_sym, :tenant_id)
        add_column table, :tenant_id, :integer
        add_index table, :tenant_id
      end
    end

    Spree::SpreeLandlord::TenantBootstrapper.new.run
  end
end
