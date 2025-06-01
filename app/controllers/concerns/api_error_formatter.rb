module ApiErrorFormatter
  extend ActiveSupport::Concern

  def api_error_formatter(error)
    case error
    when ActiveRecord::RecordInvalid
      format_record_invalid_error(error)
    when ActiveRecord::RecordNotFound
      { errors: [{ type: 'Product not found', message: error.message }] }
    else
      { errors: [{ message: 'An unexpected error occurred' }] }
    end
  end

  private

  def format_record_invalid_error(error)
    record = error.record
    type = 'Product error' if record.is_a?(CartItem)

    {
      errors: record.errors.map do |record_error|
        next if record.is_a?(CartItem) && record_error.match?(:total_price)

        {
          type: type || record_error.type,
          message: record_error.full_message
        }
      end.compact
    }
  end
end
