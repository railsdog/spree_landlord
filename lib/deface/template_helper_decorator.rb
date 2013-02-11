module Deface
  TemplateHelper.module_eval do
    # I'm decorating this only to change one line: the @lookup_context view_paths
    # LIES.  need to create a new lookup context EVERY TIME so old tenant paths aren't help onto

    # used to find source for a partial or template using virtual_path
    def load_template_source(virtual_path, partial, apply_overrides=true)
      parts = virtual_path.split("/")
      prefix = []
      if parts.size == 2
        prefix << ""
        name = virtual_path
      else
        prefix << parts.shift
        name = parts.join("/")
      end

      #this needs to be reviewed for production mode, overrides not present
      Rails.application.config.deface.enabled = apply_overrides
      view_paths = ActionView::PathSet.new([tenant_view_path]) + ActionController::Base.view_paths
      @lookup_context = ActionView::LookupContext.new(view_paths, {:formats => [:html]})

      view = @lookup_context.disable_cache do
        @lookup_context.find(name, prefix, partial)
      end

      if view.handler.to_s == "Haml::Plugin"
        Deface::HamlConverter.new(view.source).result
      else
        view.source
      end
    end

    private
      def tenant_view_path
        File.expand_path(Rails.application.root).to_s + "/app/tenants/#{Spree::Tenant.current_tenant.shortname}/views"
      end
  end
end
