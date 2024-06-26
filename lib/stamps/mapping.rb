module Stamps

  # == Mapping Module
  #
  # Provides an interface to convert hash keys and values into a
  # hash that can be easily coverted to an xml document that the
  # web service can understand.
  #
  #
  module Mapping

    class Account < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :PostageBalance, :from => :postage_balance
    end

    class AuthenticateUser < Hashie::Trash
      property :Credentials,   :from => :credentials

      def credentials=(val)
        self[:Credentials] = Credentials.new(val)
      end
    end

    class Credentials < Hashie::Trash
      property :IntegrationID, :from => :integration_id
      property :Username,      :from => :username
      property :Password,      :from => :password
    end

    class PostageBalance < Hashie::Trash
      property :AvailablePostage,  :from => :available_postage
      property :ControlTotal,      :from => :control_total
    end

    class GetPostageStatus < Hashie::Trash
      property :TransactionID, :from => :transaction_id
    end

    class Rates < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :Rate,          :from => :rate
      property :Carrier,       :from => :carrier
    end

    class Rate < Hashie::Trash
      property :FromZIPCode,             :from => :from_zip_code
      property :From,                    :from => :from
      property :ToZIPCode,               :from => :to_zip_code
      property :ToCountry,               :from => :to_country
      property :To,                      :from => :to
      property :Amount,                  :from => :amount
      property :MaxAmount,               :from => :max_amount
      property :ServiceType,             :from => :service_type
      property :PrintLayout,             :from => :print_layout
      property :DeliverDays,             :from => :deliver_days
      property :Error,                   :from => :error
      property :WeightLb,                :from => :weight_lb
      property :WeightOz,                :from => :weight_oz
      property :PackageType,             :from => :package_type
      property :RequiresAllOf,           :from => :requires_all
      property :Length,                  :from => :length
      property :Width,                   :from => :width
      property :Height,                  :from => :height
      property :ShipDate,                :from => :ship_date
      property :InsuredValue,            :from => :insured_value
      property :RegisteredValue,         :from => :registration_value
      property :CODValue,                :from => :cod_value
      property :DeclaredValue,           :from => :declared_value
      property :NonMachinable,           :from => :non_machinable
      property :RectangularShaped,       :from => :rectangular
      property :Prohibitions,            :from => :prohibitions
      property :Restrictions,            :from => :restrictions
      property :Observations,            :from => :observations
      property :Regulations,             :from => :regulations
      property :GEMNotes,                :from => :gem_notes
      property :MaxDimensions,           :from => :max_dimensions
      property :DimWeighting,            :from => :dim_weighting
      property :AddOns,                  :from => :add_ons
      property :EffectiveWeightInOunces, :from => :effective_weight_in_ounces
      property :IsIntraBMC,              :from => :is_intra_bmc
      property :Zone,                    :from => :zone
      property :RateCategory,            :from => :rate_category
      property :ToState,                 :from => :to_state
      property :CubicPricing,            :from => :cubic_pricing

      # Maps :rate to AddOns map
      def add_ons=(addons)
        self[:AddOns] = AddOnsArray.new(:add_on_v9 => addons[:add_on_v9], :add_on_v17 => addons[:add_on_v17])
      end

      def from=(from_address)
        self[:From] = Address.new(from_address)
      end

      def to=(to_address)
        self[:To] = Address.new(to_address)
      end
    end

    class AddOnsArray < Hashie::Trash
      property :AddOnV9,     :from => :add_on_v9
      property :AddOnV17,     :from => :add_on_v17

      def add_on_v9=(vals)
        return unless vals
        self[:AddOnV9] = vals.map{ |value| AddOnV9.new(value).to_hash }
      end

      def add_on_v17=(vals)
        return unless vals
        self[:AddOnV17] = vals.map{ |value| AddOnV17.new(value).to_hash }
      end
    end

    class AddOnV9 < Hashie::Trash
      property :Amount,                    :from => :amount
      property :AddOnType,                 :from => :add_on_type
      property :ProhibitedWithAnyOf,       :from => :prohibited_with_any_of
      property :MissingData,               :from => :missing_data
      def prohibited_with_any_of; end
      def prohibited_with_any_of=(vals); end
      property :RequiresAllOf,             :from => :requires_all_of
    end

    class AddOnV17 < Hashie::Trash
      property :Amount,                    :from => :amount
      property :AddOnType,                 :from => :add_on_type
      property :ProhibitedWithAnyOf,       :from => :prohibited_with_any_of
      property :MissingData,               :from => :missing_data
      def prohibited_with_any_of; end
      def prohibited_with_any_of=(vals); end
      property :RequiresAllOf,             :from => :requires_all_of
    end

    class Stamp < Hashie::Trash
      property :Authenticator,                        :from => :authenticator
      property :Credentials,   :from => :credentials
      property :IntegratorTxID,                       :from => :transaction_id
      property :TrackingNumber,                       :from => :tracking_number
      property :Rate,                                 :from => :rate
      property :From,                                 :from => :from
      property :To,                                   :from => :to
      property :CustomerID,                           :from => :customer_id
      property :Customs,                              :from => :customs
      property :SampleOnly,                           :from => :sample
      property :ImageType,                            :from => :image_type
      property :EltronPrinterDPIType,                 :from => :label_resolution
      property :memo
      property :recipient_email
      property :deliveryNotification,                 :from => :notify
      property :shipmentNotificationCC,               :from => :notify_crates
      property :shipmentNotificationFromCompany,      :from => :notify_from_company
      property :shipmentNotificationCompanyInSubject, :from => :notify_in_subject
      property :rotationDegrees,                      :from => :rotation
      property :printMemo,                            :from => :print_memo
      property :nonDeliveryOption,                    :from => :non_delivery
      property :PaperSize,                            :from => :paper_size

      # Maps :from to Address map
      def from=(val)
        # Set the defult :from address from address
        if Stamps.return_address
          self[:From] = Address.new(Stamps.return_address.merge!(val))
        else
          self[:From] = Address.new(val)
        end
      end

      # Maps :to to Address map
      def to=(val)
        self[:To] = Address.new(val)
      end

      # Maps :rate to Rate map
      def rate=(val)
        self[:Rate] = Rate.new(val)
      end

      # Maps :customs to Customs map
      def customs=(val)
        self[:Customs] = Customs.new(val)
      end
    end

    class Address < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :FullName,      :from => :full_name
      property :NamePrefix,    :from => :name_prefix
      property :FirstName,     :from => :first_name
      property :MiddleName,    :from => :middle_name
      property :LastName,      :from => :last_name
      property :NameSuffix,    :from => :name_suffex
      property :Title,         :from => :title
      property :Department,    :from => :deparartment
      property :Company,       :from => :company
      property :Address1,      :from => :address1
      property :Address2,      :from => :address2
      property :City,          :from => :city
      property :State,         :from => :state
      property :ZIPCode,       :from => :zip_code
      property :ZIPCodeAddOn,  :from => :zip_code_add_on
      property :DPB,           :from => :dpb
      property :CheckDigit,    :from => :check_digit
      property :Province,      :from => :province
      property :PostalCode,    :from => :postal_code
      property :Country,       :from => :country
      property :Urbanization,  :from => :urbanization
      property :PhoneNumber,   :from => :phone_number
      property :Extension,     :from => :extentsion
      property :CleanseHash,   :from => :cleanse_hash
      property :OverrideHash,  :from => :override_hash
    end

    class CleanseAddress < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :Address,       :from => :address

      # Maps :address to Address map
      def address=(val)
        self[:Address] = Address.new(val)
      end
    end

    class PurchasePostage < Hashie::Trash
      property :Authenticator,  :from => :authenticator
      property :Credentials,   :from => :credentials
      property :IntegratorTxID, :from => :transaction_id
      property :PurchaseAmount, :from => :amount
      property :ControlTotal,   :from => :control_total
    end

    class GetPurchaseStatus < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :TransactionID, :from => :transaction_id
    end

    class CancelStamp< Hashie::Trash
      property :Authenticator,  :from => :authenticator
      property :Credentials,   :from => :credentials
      property :StampsTxID,     :from => :transaction_id
      property :TrackingNumbers, :from => :tracking_numbers
    end

    class CarrierPickup < Hashie::Trash
      property :Authenticator,               :from => :authenticator
      property :Credentials,   :from => :credentials
      property :FirstName,                   :from => :first_name
      property :LastName,                    :from => :last_name
      property :Company,                     :from => :company
      property :Address,                     :from => :address
      property :SuiteOrApt,                  :from => :suite,  :default => ''
      property :City,                        :from => :city
      property :State,                       :from => :state
      property :ZIP,                         :from => :zip
      property :ZIP4,                        :from => :zip_four
      property :PhoneNumber,                 :from => :phone
      property :PhoneExt,                    :from => :phone_ext
      property :NumberOfExpressMailPieces,   :from => :express_mail_count
      property :NumberOfPriorityMailPieces,  :from => :priority_mail_count
      property :NumberOfInternationalPieces, :from => :international_mail_count
      property :NumberOfOtherPieces,         :from => :other_mail_count
      property :TotalWeightOfPackagesLbs,    :from => :total_weight
      property :PackageLocation,             :from => :location
      property :SpecialInstruction,          :from => :special_instruction
    end

    class Customs < Hashie::Trash
      property :ContentType,       :from => :content_type
      property :Comments,          :from => :comments
      property :LicenseNumber,     :from => :license_number
      property :CertificateNumber, :from => :certificate_number
      property :InvoiceNumber,     :from => :invoice_number
      property :OtherDescribe,     :from => :other_describe
      property :CustomsLines,      :from => :customs_lines
      property :SendersCustomsReference, :from => :senders_customs_reference

      # Maps :customs CustomsLine map
      def customs_lines=(val)
        # Important:  Must call to_hash to force re-ordering!
        self[:CustomsLines] = CustomsLinesArray.new(val).to_hash
      end
    end

    class CustomsLinesArray < Hashie::Trash
      property :CustomsLine,     :from => :custom
      def custom=(customs)
        self[:CustomsLine] = customs.collect{ |val| CustomsLine.new(val).to_hash }
      end
    end

    class CustomsLine < Hashie::Trash
      property :Description,     :from => :description
      property :Quantity,        :from => :quantity
      property :Value,           :from => :value
      property :WeightLb,        :from => :weight_lb
      property :WeightOz,        :from => :weight_oz
      property :HSTariffNumber,  :from => :hs_tariff_number
      property :CountryOfOrigin, :from => :country_of_origin
    end

    class TrackShipment < Hashie::Trash
      property :Authenticator, :from => :authenticator
      property :Credentials,   :from => :credentials
      property :StampsTxID,    :from => :stamps_transaction_id
    end

    class CreateManifest < Hashie::Trash
      property :Authenticator,     :from => :authenticator
      property :IntegratorTxID,    :from => :integrator_tx_id
      property :StampsTxIds,       :from => :stamps_tx_ids
      property :TrackingNumbers,   :from => :tracking_numbers
      property :ShipDate,          :from => :ship_date
      property :FromAddress,       :from => :from_address
      property :ImageType,         :from => :image_type
      property :PrintInstructions, :from => :print_instructions
      property :ManifestType,      :from => :manifest_type

      def from_address=(from_address)
        self[:FromAddress] = Address.new(from_address)
      end

      def stamps_tx_ids=(tx_ids)
        self[:StampsTxIds] = tx_ids.map {|id| {guid:id}}
      end

      def tracking_numbers=(tracking_numbers)
        self[:TrackingNumbers] = tracking_numbers.map {|n| {string:n}}
      end
    end

    class Reprint < Hashie::Trash
      property :Authenticator,     :from => :authenticator
      property :IntegratorTxID,    :from => :integrator_tx_id
      property :StampsTxId,       :from => :stamps_tx_id
      property :TrackingNumber,   :from => :tracking_number
      property :ImageType,         :from => :image_type
      property :RotationDegrees,   :from => :rotation_degrees
      property :PaperSize,         :from => :paper_size
      property :StartRow,         :from => :start_row
      property :StartColumn,         :from => :start_column

      def stamps_tx_id=(tx_id)
        self[:StampsTxId] = {guid:tx_id}
      end
    end

  end
end
