module Api
  module V1
    class BaseOperation
      extend Dry::Initializer

      def self.call(...)
        new(...).call
      end

      private

      def format_errors(errors)
        errors.to_h.transform_keys { |key| key.to_s.sub("course.", "") }
      end
    end
  end
end
