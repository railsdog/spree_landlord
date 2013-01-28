module Spree
  include SpreeLandlord::Tenantizable

  Landlord.model_names.each do |model|
    tenantize(model)
  end
end
