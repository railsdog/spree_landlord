module Spree
  module SpreeLandlord
    class TenantNotFound < StandardError; end

    class TenantFinder
      def find_target_tenant(request)
        domain_tenant = Spree::Tenant.find_by_domain(request.domain)

        subdomain_tenant = nil
        shortname = request.subdomains.first
        if shortname.present?
          subdomain_tenant = Spree::Tenant.find_by_shortname(shortname.downcase)
        end

        if is_master_tenant?(domain_tenant)
          if subdomain_tenant.present?
            return subdomain_tenant
          else
            raise_tenant_not_found_error(request)
          end
        else #not master tenant
          if domain_tenant.present? 
            return domain_tenant
          elsif subdomain_tenant.present?
            return subdomain_tenant
          elsif request.domain == 'localhost' || request.domain.nil?
            return Spree::Tenant.master
          end
        end

        raise_tenant_not_found_error(request)
      end

      private 

      def is_master_tenant?(tenant)
        Spree::Tenant.master == tenant
      end

      def raise_tenant_not_found_error(request)
        full_domain = request.domain
        shortname = request.subdomains.first
        if shortname.present?
          full_domain = shortname + '.' + full_domain
        end
        raise TenantNotFound, "No tenant could be found for '#{full_domain}'"
      end

    end
  end
end

