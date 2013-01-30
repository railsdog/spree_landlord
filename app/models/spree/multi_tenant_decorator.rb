module Spree
  Landlord.model_names.each do |model|
    model.send(:include, SpreeLandlord::TenantedModel)
  end
end
