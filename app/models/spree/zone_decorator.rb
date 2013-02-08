Spree::Zone.class_eval do
  # ugly hack to remove the uniqueness validator on name
  _validate_callbacks.reject! do |callback|
    callback.raw_filter.kind_of?(ActiveRecord::Validations::UniquenessValidator) &&
      callback.raw_filter.attributes == [:name]
  end

  validates :name, :uniqueness => { :scope => :tenant_id }
end
