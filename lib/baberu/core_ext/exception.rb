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
        def add_backtrace_mapping(path, line_map)
          unless ::Exception.class_variable_defined?(:@@baberu_mapping)
            ::Exception.class_variable_set(:@@baberu_mapping, {})
          end

          mapping = ::Exception.class_variable_get(:@@baberu_mapping)
          mapping[path] = line_map
        end
      end

      module Prepend
        def backtrace
          locations = backtrace_locations
          return super unless locations
          return unless ::Exception.class_variable_defined?(:@@baberu_mapping)

          mapping = ::Exception.class_variable_get(:@@baberu_mapping)
          locations.map { |l|
            next l.to_s unless mapping.key?(l.path)

            l.to_s.sub(/^([^:]+):(\d+):/) { "#{$1}:#{mapping[l.path][$2.to_i]}:" }
          }.join("\n")
        end
      end
    end
  end
end
