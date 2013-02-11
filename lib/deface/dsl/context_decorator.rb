module Deface
  module DSL
    Context.class_eval do
      def tenant_name(value)
        @options[:tenant_name] = value
      end
    end
  end
end
