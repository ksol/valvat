# frozen_string_literal: true

require_relative 'lookup/vies'
require_relative 'lookup/hmrc'

class Valvat
  class Lookup
    def initialize(vat, options = {})
      @vat = Valvat(vat)
      @options = options || {}
      @options[:requester] ||= @options[:requester_vat]
    end

    def validate
      return false if !@options[:skip_local_validation] && !@vat.valid?
      return handle_error(response[:error]) if response[:error]

      response[:valid] && show_details? ? response : response[:valid]
    end

    class << self
      def validate(vat, options = {})
        new(vat, options).validate
      end
    end

    private

    def valid?
      response[:valid]
    end

    def response
      @response ||= webservice.new(@vat, @options).perform
    end

    def webservice
      case @vat.vat_country_code
      when 'GB' then HMRC
      else
        VIES
      end
    end

    def show_details?
      @options[:requester] || @options[:detail]
    end

    def handle_error(error)
      if error.is_a?(MaintenanceError)
        raise error if @options[:raise_error]
      else
        raise error unless @options[:raise_error] == false
      end
    end
  end
end
