module Deface
  Environment::Overrides.class_eval do

    def default_override_paths
      # I had app/tenants/*/overrides here, but we have to be careful:
      # In the template_helper#load_template_source, the lookup context
      # searches all view paths, so i want to restrict it per-tenant
      ["app/tenants","app/overrides"]
    end

    # TODO: DEFACE - create a pull request to use the method above vs what's currently there
    private
      def enumerate_and_load(paths, root)
        paths ||= default_override_paths

        paths.each do |path|
          if Rails.version[0..2] == "3.2"
            # add path to watchable_dir so Rails will call to_prepare on file changes
            # allowing overrides to be updated / reloaded in development mode.
            Rails.application.config.watchable_dirs[root.join(path).to_s] = [:rb, :deface]
          end

          Dir.glob(root.join path, "**/*.rb") do |c|
            Rails.application.config.cache_classes ? require(c) : load(c)
          end

          Dir.glob(root.join path, "**/*.deface") do |c|
            Rails.application.config.cache_classes ? require(c) : Deface::DSL::Loader.load(c)
          end
        end
      end
  end
end
