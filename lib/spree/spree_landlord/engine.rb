module Spree
  module SpreeLandlord
    class Engine < Rails::Engine
      require 'spree/core'
      isolate_namespace Spree
      engine_name 'spree_landlord'

      config.autoload_paths += %W(#{config.root}/lib)
      config.current_tenant_name = ENV['TENANT_NAME']

      # use rspec for tests
      config.generators do |g|
        g.test_framework :rspec
      end

      rake_tasks do
        %w{precompile}.each { |r| load File.join([File.dirname(__FILE__) , "../../tasks/#{r}.rake"]) }
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
        Spree::Ability.register_ability(Spree::TenantAbility)

        ActiveSupport.on_load(:action_controller) do
          include Spree::SpreeLandlord::TenantHelpers
        end
      end

      config.to_prepare &method(:activate).to_proc

      # based on `initializer "sprockets.environment"` in rails-3.2/actionpack/lib/sprockets/railtie.rb
      initializer "landlord.assets.environment", :group => :all do |app|
        Rails::Application.class_eval do
          attr_accessor :tenants_assets
          attr_accessor :tenants_digests
        end

        Sprockets::Helpers::RailsHelper.class_eval do
          def asset_prefix
            if Spree::Tenant.current_tenant_id && Rails.application.tenants_assets && Rails.application.tenants_assets[Spree::Tenant.current_tenant.shortname]
              "/tenants/#{Spree::Tenant.current_tenant.shortname}#{Rails.application.config.assets.prefix}"
            elsif Rails.application.config.current_tenant_name
              "/tenants/#{Rails.application.config.current_tenant_name}#{Rails.application.config.assets.prefix}"
            else
              Rails.application.config.assets.prefix
            end
          end

          def asset_environment
            if Spree::Tenant.current_tenant_id && Rails.application.tenants_assets && Rails.application.tenants_assets[Spree::Tenant.current_tenant.shortname]
              Rails.application.tenants_assets[Spree::Tenant.current_tenant.shortname]
            elsif Rails.application.config.current_tenant_name
              Rails.application.tenants_assets[Rails.application.config.current_tenant_name]
            else
              Rails.application.assets
            end
          end

          def asset_digests
            if Spree::Tenant.current_tenant_id && Rails.application.tenants_assets && Rails.application.tenants_assets[Spree::Tenant.current_tenant.shortname]
              Rails.application.tenants_digests[Spree::Tenant.current_tenant.shortname]
            elsif Rails.application.config.current_tenant_name
              Rails.application.tenants_digests[Rails.application.config.current_tenant_name]
            else
              Rails.application.config.assets.digests
            end
          end
        end

        config = app.config
        next unless config.assets.enabled

        tenants_root = app.root + 'app' + 'tenants'
        next unless tenants_root.exist?

        tenants_root.children(false).each do |tenant_name|
          tenant_root = tenants_root + tenant_name
          if tenant_root.directory?
            require 'sprockets'

            app.tenants_assets ||= {}
            app.tenants_assets[tenant_name.to_s] = Sprockets::Environment.new(app.root.to_s) do |env|
              env.version = ::Rails.env + "-#{config.assets.version}"

              if config.assets.logger != false
                env.logger  = config.assets.logger || ::Rails.logger
              end

              if config.assets.cache_store != false
                env.cache = ActiveSupport::Cache.lookup_store(config.assets.cache_store) || ::Rails.cache
              end
            end

            if config.assets.manifest
              path = File.join(config.assets.manifest, 'tenants', tenant_name, "manifest.yml")
            else
              path = File.join(Rails.public_path, 'tenants', tenant_name, config.assets.prefix, "manifest.yml")
            end

            app.tenants_digests ||= {}
            if File.exist?(path)
              app.tenants_digests[tenant_name.to_s] = YAML.load_file(path)
            end

            ActiveSupport.on_load(:action_view) do
              include ::Sprockets::Helpers::RailsHelper
              app.tenants_assets[tenant_name.to_s].context_class.instance_eval do
                include ::Sprockets::Helpers::IsolatedHelper
                include ::Sprockets::Helpers::RailsHelper
              end
            end

            if defined?(::Sass::Rails::Railtie::SassContext)
              app.tenants_assets[tenant_name.to_s].context_class.extend(::Sass::Rails::Railtie::SassContext)
              app.tenants_assets[tenant_name.to_s].context_class.sass_config = app.config.sass
            end
          end
        end
      end

      config.after_initialize do |app|
        Spree::SpreeLandlord::Assets::Bootstrap.new(app).run
      end
    end
  end
end
