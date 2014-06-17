require 'savon'
require 'logger'

module UltraSOAP

  class Client

    attr :logger
    attr :logdest
    attr :transaction_id
    attr :use_transactions
    attr :settings

    # Constructor
    def initialize(ultra_wsdl, username, password, use_transactions=false, logfile='./ultrasoap.log', logging=true, log_lev='debug')
      # Mandatory parameters check
      return nil unless (ultra_wsdl.nil? or username.nil? or password.nil?)

      @transaction_id = nil

      # Setting up log destination and logger instance
      @logdest = logfile

      @logger = Logger.new(logfile)

      begin
        @client = Savon.client do
          wsdl ultra_wsdl
          env_namespace 'soapenv'
          wsse_auth(username, password)
          element_form_default :unqualified
          log logging
          log_level log_lev.to_sym
          pretty_print_xml true
        end
        
        # Setting local variables
        @use_transactions = use_transactions

      rescue Exception => e  
        @logger.error("Error in ultrasoap.initialize: " + e.message)
        raise Error, 'Error in ultrasoap initialization, check log file'
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

  end
end
