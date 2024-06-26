require 'hashie'
require 'savon'
require File.expand_path('../response', __FILE__)

module Stamps

  # Defines HTTP request methods
  module Request

    # Perform an HTTP request
    def request(web_method, params, raw=false)
      client = Savon.client do |globals|
        globals.endpoint self.endpoint
        globals.namespace self.namespace
        globals.namespaces("xmlns:tns" => self.namespace)
        globals.log self.log_messages
        globals.logger Logger.new(STDOUT)
        globals.raise_errors false
        globals.headers({ "SoapAction" => formatted_soap_action(web_method) })
        globals.element_form_default :qualified
        globals.namespace_identifier self.namespace_identifier
        globals.ssl_version :TLSv1_2
        globals.open_timeout self.open_timeout
        globals.read_timeout self.read_timeout
      end

      if self.use_credentials
        params[:Credentials] = Stamps::Mapping::Credentials.new(credentials)
      end

      response = client.call(web_method, :message => params.to_hash)

      Stamps::Response.new(response).to_hash
    end

    # Get the Authenticator token. By using an Authenticator, the integration
    # can be sure that the conversation between the integration and the SWS
    # server is kept in sync and no messages have been lost.
    #
    def authenticator_token
      @authenticator ||= self.get_authenticator_token
    end

    # Make Authentication request for the user
    #
    def get_authenticator_token
      return nil if self.use_credentials

      response_hash = self.request('AuthenticateUser',
        Stamps::Mapping::AuthenticateUser.new(:credentials => credentials)
      )
      if response_hash[:authenticate_user_response] != nil
        response_hash[:authenticate_user_response][:authenticator]
      else
        raise Stamps::InvalidIntegrationID.new(response_hash[:errors][0])
      end
    end

    # Concatenates namespace and web method in a way the API can understand
    def formatted_soap_action(web_method)
      [self.namespace, web_method.to_s].compact.join('/')
    end

    def credentials
      {
        :integration_id => self.integration_id,
        :username       => self.username,
        :password       => self.password
      }
    end

  end
end
