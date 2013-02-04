Spree::User.class_eval do
  # ugly hack to remove the uniqueness validator on email
  _validate_callbacks.reject! do |callback|
    callback.raw_filter.kind_of?(ActiveRecord::Validations::UniquenessValidator) &&
      callback.raw_filter.attributes == [:email]
  end

  validates :email, :uniqueness => { :scope => :tenant_id, :allow_blank => true, :if => :email_changed? }

  self.default_scopes = []
  default_scope lambda {
    if Spree::Tenant.table_exists? && column_names.include?('tenant_id') && column_names.include?('super_admin')
      where( "#{table_name}.tenant_id = ? or #{table_name}.super_admin = ?", Spree::Tenant.current_tenant_id, true )
    end
  }

  before_save :ensure_at_least_one_super_admin_exists
  before_save :ensure_super_admin_is_admin

  protected

  def super_admin_exists?
    Spree::User.where(:super_admin => true).count > 0
  end

  def ensure_at_least_one_super_admin_exists
    unless super_admin_exists?
      super_admin_role = Spree::Role.find_or_create_by_name 'super_admin'
      self.spree_roles << super_admin_role
      self.super_admin = true
    end
  end

  def ensure_super_admin_is_admin
    if self.super_admin? && !self.has_spree_role?(:admin)
      admin_role = Spree::Role.find_or_create_by_name 'admin'
      self.spree_roles << admin_role
    end
  end
end
