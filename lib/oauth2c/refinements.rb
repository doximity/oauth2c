module OAuth2c
  module Refinements
    refine Hash do
      def slice(*keys)
        keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
        keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
      end

      def symbolize_keys
        transform_keys{ |key| key.to_sym rescue key }
      end

      def stringify_keys
        transform_keys(&:to_s)
      end

      def transform_keys
        return enum_for(:transform_keys) { size } unless block_given?
        result = {}
        each_key do |key|
          result[yield(key)] = self[key]
        end
        result
      end
    end
  end
end
