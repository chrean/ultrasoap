require 'savon'
require 'logger'

module UltraSOAP

  class Client

    # Class variables
    @logger

    @logdest            = './ultrasoap.log'
    @logging            = false
    @log_level          = 'error'
    @test_wsdl          = 'https://testapi.ultradns.com/UltraDNS_WS/v01?wsdl'
    @prod_wsdl          = 'https://ultra-api.ultradns.com/UltraDNS_WS/v01?wsdl'
    @environment        = 'production'
    @transaction_id     = nil
    @use_transactions   = false

    class << self
      attr_accessor :logdest
      attr_accessor :logging
      attr_accessor :log_level
      attr_accessor :transaction_id
      attr_accessor :test_wsdl
      attr_accessor :prod_wsdl
      attr_accessor :environment
      attr_accessor :use_transactions
    end

    # Instance variables
    attr_accessor :logging
    attr_accessor :loglevel

    # Constructor
    def initialize()
      # Exits if username or password aren't specified.
      return nil unless !(Settings.username.nil? or Settings.password.nil?)

      username = Settings.username
      password = Settings.password

      @environment = Settings['environment'] || Client.environment

      # We don't need the following to be instance variables
      ultra_wsdl = (@environment == 'test' ? (Settings['test_wsdl'] || Client.test_wsdl) : (Settings['prod_wsdl'] || Client.prod_wsdl))

      # Setting up parameter values, if provided. If not, defaults are assumed

      @use_transactions = Settings['use_transactions'] || Client.use_transactions
      @logdest = Settings['logfile'] || Client.logdest

      @logger = Logger.new(@logdest)
      
      logging = Settings['logging'] || Client.logging

      log_lev = Settings['log_level'] || Client.log_level

      begin
        # For some reason, if I use the instance variable, Savon.client doesn't work properly

        @client = Savon.client do
          wsdl ultra_wsdl
          env_namespace 'soapenv'
          wsse_auth(username, password)
          element_form_default :unqualified
          log logging
          log_level log_lev.to_sym
          pretty_print_xml true
        end
      rescue Exception => e  
        @logger.error("Error in ultrasoap.initialize: " + e.message)
        raise 'Error in ultrasoap initialization, check log file'
      end
    end

    # Main method to send SOAP requests
    #
    # Parameters:
    # * method: the SOAP send_request
    # * message: the message hash
    def send_request(method, message, strip_namespaces=true)
      # If the client is using transactions, append the transaction id to the message hash
      if @use_transactions == true
        transaction_hash = { :transaction_id => @transaction_id }
        message.merge(transaction_hash)
      end

      begin
        @response = @client.call method, message: message
        return Nokogiri::XML(@response.to_xml).remove_namespaces!
      rescue Exception => e
        @logger.error("Error in ultrasoap.send_request: " + e.message)
        return nil
      end
    end

    # Starts a transaction and sets the @transaction_id variable
    def transaction_start
      begin
        response = self.send_request :start_transaction
        xml_response = Nokogiri::XML(response.to_xml).remove_namespaces!
        @transaction_id = xml_response.xpath("//transactionId/text()")
      rescue Exception => e
        @logger.error("Error in ultrasoap.transaction_start: " + e.message)
      end
    end

    # Rolls back the current transaction
    def transaction_rollback
      return nil unless @transaction_id != nil

      message = {
        :transaction_id => @transaction_id.to_s
      }

      begin
        trans_rollback = self.send_request :rollback_transaction, message
      rescue Exception => e
        @logger.error("Error in ultrasoap.transaction_rollback: " + e.message)
      end
    end

    # Commit the current transaction
    def transaction_commit
      return nil unless @transaction_id != nil
      
      message = {
        :transaction_id => @transaction_id.to_s
      }

      begin
        trans_commit = self.send_request :commit_transaction, message
      rescue Exception => e
        @logger.error("Error in ultrasoap.transaction_commit: " + e.message)
      end
    end

    # Helper method to retrieve load balancing pools data
    # Parameters:
    # - zone (don't forget the trailing dot)
    def get_lb_pools(zone)
      message = {
        :zone_name    => zone,
        :lb_pool_type => 'SB'
      }

      begin
        response = self.send_request :get_load_balancing_pools_by_zone, message
        return response
      rescue Exception => e
        @logger.error("Error in retrieving SB pools for the zone #{zone}: #{e.message}")
        return nil
      end
    end

    # Helper method to retrieve Pool's records
    # Parameters:
    # - poolID
    def get_pool_records(pool_id)
      message = {
        :pool_id => pool_id.to_s
      }

      begin
        return self.send_request :get_pool_records, message
      rescue Exception => e
        @logger.error("Error while retrieving Pool Records for the Pool ID #{pool_id.to_s}: #{e.message}")
      end
    end

    # LOOKUP methods

    def lookup_pool_type(pt_code)
      case pt_code.to_s
      when 'SB'
        'SiteBacker'
      when 'RD'
        'Resource Distribution'
      when 'TC'
        'Traffic Controller'
      else
        'Other'
      end
    end

    def lookup_response_method(rm_code)
      case rm_code.to_s
      when 'FX'
        'Fixed'
      when 'RR'
        'Round Robin'
      when 'RD'
        'Random'
      end
    end

  end
end