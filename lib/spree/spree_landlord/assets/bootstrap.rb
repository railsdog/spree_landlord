# based on rails-3.2/actionpack/lib/sprockets/bootstrap.rb

require 'pathname'

module Spree
  module SpreeLandlord
    module Assets
      class Bootstrap
        def initialize(app)
          @app = app
        end

        # TODO: Get rid of config.assets.enabled
        def run
          app, config = @app, @app.config
          return unless app.tenants_assets
          app.tenants_assets.each do |tenant, tenant_assets|
            (Pathname.new(tenant_assets.root) + 'app' + 'tenants' + tenant + 'assets').children.select { |d| d.directory? }.each do |path|
              tenant_assets.append_path(path)
            end
            config.assets.paths.each { |path| tenant_assets.append_path(path) }

            if config.assets.compress
              # temporarily hardcode default JS compressor to uglify. Soon, it will work
              # the same as SCSS, where a default plugin sets the default.
              unless config.assets.js_compressor == false
                tenant_assets.js_compressor = Sprockets::LazyCompressor.new { Sprockets::Compressors.registered_js_compressor(config.assets.js_compressor || :uglifier) }
              end

              unless config.assets.css_compressor == false
                tenant_assets.css_compressor = Sprockets::LazyCompressor.new { Sprockets::Compressors.registered_css_compressor(config.assets.css_compressor) }
              end
            end

            if config.assets.compile
              app.routes.prepend do
                mount tenant_assets => "tenants/#{tenant}/#{config.assets.prefix}"
              end
            end

            if config.assets.digest
              tenant_assets = tenant_assets.index
            end
          end
        end
      end
    end
  end
end
