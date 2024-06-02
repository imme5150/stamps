module Stamps
  class Client

    # == Stamp Module
    #
    # Stamp provides an interface to creating and cancelling postage labels
    #
    #
    module Stamp

      # Creates postage labels.
      #
      # In order to successfully create postage labels, the following steps
      # must happen:
      #
      # 1. Authentiation -  identify the user and ensure that the user is
      #    authorized to perform the operation.
      #
      # 2. CleanseAddress - Ship-to addresses must be standardized based on
      #    USPS rules for proper address conventions before a shipping label
      #    can be issued.
      #
      # 3. GetRates - A call to GetRates will allow users to view and select
      #    the best shipping service for their needs.
      #
      # @param params [Hash] authenticator, address, rates.
      # @return [Hash]
      #
      def create!(params = {})
        params[:authenticator] = authenticator_token unless params[:authenticator]
        response = request('CreateIndicium', Stamps::Mapping::Stamp.new(params))
        response[:errors].empty? ? response[:create_indicium_response] : response
      end

      # Reprint postage label
      #
      # The ReprintIndicium method returns data for a previously issued indicium to allow for label reprint functionality in the event of printing or formatting errors. Labels may be reprinted up to 7 days after label creation. This method may also be used to return indicia with non-material modifications for the purpose of appropriate print settings. For example, ReprintIndicium can be used to return an existing indicium with an alternative ImageType, alternative RotationDegrees, or, for sheets containing multiple labels, alternative row/column print locations.
      # Note: When reprinting labels, users must destroy the original labels that printed in error. Labels must be used only once.
      # Note: Integrations are required to call ReprintIndicium to retrieve a label image for a reprint request. Labels should not be stored client-side after initial print.
      #
      # More info: https://developer.stamps.com/soap-api/reference/swsimv135.html#reprintindicium
      # Only one of IntegratorTxId, StampsTxId, or TrackingNumber should be provided to identify the original label.
      #
      def reprint(params)
        params[:authenticator] = authenticator_token unless params[:authenticator]
        response = request('ReprintIndicium', {indiciumRequest:Stamps::Mapping::Reprint.new(params).to_hash})
        response[:errors].empty? ? response[:reprint_indicium_response][:reprint_indicium_result] : response
      end

      # Refunds postage and voids the shipping label
      #
      # @param [Hash] authenticator
      #
      def cancel!(params = {})
        params[:authenticator] = authenticator_token unless params[:authenticator]
        response = request('CancelIndicium', Stamps::Mapping::CancelStamp.new(params))
        response[:errors].empty? ? response[:cancel_indicium_response] : response
      end

      # Returns an array of tracking events
      #
      # @param [String] the transaction id of the stamp
      #
      def track(stamps_transaction_id)
        params = {
          :authenticator => authenticator_token,
          :stamps_transaction_id => stamps_transaction_id
        }
        response = request('TrackShipment', Stamps::Mapping::TrackShipment.new(params))
        response[:errors].empty? ? response[:track_shipment_response] : response
      end

      # CreateManifest
      #
      # The CreateManifest method generates an end of day manifest for previously created indicium (e.g. SCAN form). The SWS API will return a URL or a series of URLs separated by spaces for the manifest. A SCAN form specifically can accept maximum 1,000 labels.  Each label can only be added once to a single SCAN form.
      #
      # @param params [Hash] authenticator, integrator_tx_id, stamps_tx_ids, tracking_numbers, ship_date, from_address, image_type, print_instructions, manifest_type
      # stamps_tx_ids:	[Array of strings] Collection of stamps_tx_ids from previous CreateIndicium calls. Can be null if ShipDate is provided.
      # tracking_numbers: Collection of Tracking Numbers from previous CreateIndicium calls. Can be used as an alternative to StampsTxIDs. Can be null if ShipDate is provided.
      # ship_date:  Effective when StampsTxIDs is null. When ShipDate is non-null, all available prints (that have not been cancelled or added to another SCAN form) from the specified ShipDate are included on SCAN form. Can be null when using StampsTxIDs or Tracking Numbers
      # image_type: Image type of SCAN form (Auto, Gif, Jpg, Pdf, Png, etc.) If the ImageType is not PDF, the response string could include multiple URLs separated by spaces
      # print_instructions: [boolean] Indicates if the instruction page is generated. Optional, defaults to false
      # manifest_type Optional, defaults to 'ScanForm'
      #
      # @return [Hash]
      #
      # https://developer.stamps.com/soap-api/reference/swsimv135.html#createmanifest
      #
      def create_manifest(params = {})
        params[:authenticator] ||= authenticator_token
        params[:print_instructions] = false if !params.has_key?(:print_instructions)
        response = request('CreateManifest', Stamps::Mapping::CreateManifest.new(params))
        response[:errors].empty? ? response[:create_manifest_response][:end_of_day_manifests][:end_of_day_manifest][:manifest_url] : response
      end

    end
  end
end
