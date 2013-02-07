module Spree
  class TenantAbility
    include CanCan::Ability

    def initialize(user)
      if user.super_admin? && user.has_spree_role?(:admin)
        can :manage, Spree::Tenant
        can :grant_super_admin, Spree::User
      else
        cannot :grant_super_admin, Spree::User
      end

      # if you are not a super_admin, you can not do
      # _anything_ to a super_admin Spree::User
      [:manage, :admin, :edit, :update, :delete].each do |action|
        if !user.super_admin
          cannot action, Spree::User, super_admin: true
        end
      end
    end

    Spree::Ability.register_ability(Spree::TenantAbility)
  end
end
