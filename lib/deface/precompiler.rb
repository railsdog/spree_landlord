module Deface
  class Precompiler

    extend Deface::TemplateHelper

    def self.precompile
      base_path = Rails.root.join("app/compiled_views")

      # temporarily configures deface env and loads
      # all overrides so we can precompile
      unless Rails.application.config.deface.enabled
        Rails.application.config.deface = Deface::Environment.new
        Rails.application.config.deface.overrides.early_check
        Rails.application.config.deface.overrides.load_all Rails.application
      end

      Rails.application.config.deface.overrides.all.each do |virtual_path,overrides|

        Spree::Tenant.all.each do |tenant|
          Spree::Tenant.set_current_tenant tenant

          # we have a virtual_path and the names of all applicable overrides for
          # that virtual_path.

          # We can have different tenants as well, so let's grab
          # every distinct tenant and write to each tenant directory
          all_overrides = Rails.application.config.deface.overrides.find(virtual_path: virtual_path.to_s)
          base_overrides = all_overrides.select {|override| !override.args[:tenant_name].present?}
          tenant_overrides = all_overrides.select {|override| override.args[:tenant_name] == tenant.shortname}

          template_path = tenant_overrides.present? ? 
          base_path.join( "tenants/#{tenant.shortname}/#{virtual_path}.html.erb") :
            base_path.join( "#{virtual_path}.html.erb")

          FileUtils.mkdir_p template_path.dirname
          begin
            source = load_template_source(virtual_path.to_s, false, true)
            if source.blank?
              raise "Compiled source was blank for '#{virtual_path}'"
            end

            File.open(template_path, 'w') {|f| f.write source } 
          rescue Exception => e
            puts "Unable to precompile '#{virtual_path}' due to: "
            puts e.message
          end
        end
      end
    end
  end
end
