# frozen_string_literal: true

module Baberu
  module CoreExt
    module Exception
      module_function

      def apply
        return if @applied

        @applied = true
        ::Exception.extend(Extend)
        ::Exception.prepend(Prepend)
      end

      module Extend
        def register_mapping(path, line_map)
          ::Exception.class_variable_set(:@@path, path)
          ::Exception.class_variable_set(:@@line_map, line_map)
        end
      end

      module Prepend
        def backtrace
          locations = backtrace_locations
          return super unless locations

          path = ::Exception.class_variable_get(:@@path)
          line_map = ::Exception.class_variable_get(:@@line_map)

          locations.map { |l|
            next l.to_s if l.path != path

            l.to_s.sub(/^([^:]+):(\d+):/) { "#{$1}:#{line_map[$2.to_i]}:" }
          }.join("\n")
        end
      end
    end
  end
end
