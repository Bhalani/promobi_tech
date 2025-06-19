class ActiveModelErrorsSerializer
  # Converts ActiveModel::Errors to a frontend-friendly hash, handling nested attributes
  def self.call(errors, parent: nil)
    result = {}
    if errors.respond_to?(:details) && errors.details.any?
      # Handle nested errors for has_many (e.g., tutors)
      errors.details.each do |attr, details_arr|
        if attr.to_s =~ /tutors/ && errors[attr].is_a?(Array)
          # Find all nested tutor errors
          errors[attr].each_with_index do |msg, idx|
            key = "tutors_attributes[#{idx}].#{attr.to_s.split('.').last}"
            result[key] ||= []
            result[key] << msg
          end
        else
          key = parent ? "#{parent}.#{attr}" : attr.to_s
          result[key] ||= []
          result[key] += Array(errors[attr])
        end
      end
    else
      # Fallback for simple errors
      errors.to_hash(true).each do |key, messages|
        result[key.to_s] = Array(messages)
      end
    end
    result
  end
end
