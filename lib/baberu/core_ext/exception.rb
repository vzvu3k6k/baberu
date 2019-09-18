# frozen_string_literal: true

module Baberu
  module CoreExt
    module Exception
      module_function

      def apply(target = ::Exception)
        # Don't extend or prepend twice to avoid conflict with other patches.
        # Module#extended (Module#included) will be invoked
        # even if the module has already been extended (prepended).
        return if @applied

        @applied = true
        target.extend(Extend)
        target.prepend(Prepend)
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

            # TODO: Use a more robust way
            l.to_s.sub(/^([^:]+):(\d+):/) { "#{$1}:#{mapping[l.path][$2.to_i]}:" }
          }.join("\n")
        end
      end
    end
  end
end
