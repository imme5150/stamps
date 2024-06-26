module Stamps
  class Client

    # Produces a list of rates for all available USPS services based
    # on the ZIP Code or the foreign country being shipped to for
    # a given package weight and size.
    #
    # == Examples:
    #
    #  Stamps.get_rates(
    #    :from_zip_code => '45440',
    #    :to_zip_code   => '45458',
    #    :weight_oz     => '8.0',
    #    :ship_date     => '2011-06-01'
    #   )
    #
    module Rate

      # Produces a list of rates matching the criteria provided in
      # the parameters
      #
      def get_rates(params = {}, carrier = 'USPS')
        rates = Stamps::Mapping::Rates.new({
          :authenticator => authenticator_token,
          :carrier       => carrier,
          :rate          => Stamps::Mapping::Rate.new(params)
        })
        response = request('GetRates', rates)
        if response[:get_rates_response].nil?
          response
        else
          response[:get_rates_response][:rates].nil? ? [] : [response[:get_rates_response][:rates][:rate]].flatten
        end
      end

      def get_rate(params = {})
        rates  = get_rates(params)
        rates.is_a?(Array) ? rates.first : rates
      end

    end
  end
end
