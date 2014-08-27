require 'net/http'
require 'net/https'
require 'openssl'

module GiroCheckout
  class GcMessage
    attr_accessor :message_url
    attr_accessor :parameters
    attr_accessor :project_secret

    #Each GiroCheckout::Message needs projectId
    #The projectSecret can be retrieved through the projectID
    #MerchantID is the same for all calls
    def initialize(project_id)
      @parameters = Hash.new(nil)
      @parameters['merchantId'] = GiroCheckout.configuration.merchantId
      @parameters['projectId'] = project_id
      @project_secret = GiroCheckout.project_secret(project_id)
    end

    def make_api_call
      @parameters['hash'] = build_hash(build_paramstring)

      uri = URI.parse(
        URI.encode(GiroCheckout.message_url(self.class.name))
      )
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      request.set_form_data(@parameters)

      response = http.request(request)
      return nil unless check_response response

      return response
    end

    def check_response response
      return false unless response 
      return false unless response.code == '200'
      raise "no hash" unless response.header['hash']
      raise "no body" unless response.body

      build_hash(response.body) == response.header['hash']
    end

    #overwrite in child classes as order of input params is important
    #builds the paramstring to be hashed as control of message authenticity
    def build_paramstring
      raise 'not implemented'
    end


    #will be used for paramstring for message sending and check of result
    def build_hash data
      digest = OpenSSL::Digest::Digest.new('md5')
      OpenSSL::HMAC.hexdigest(digest, @project_secret, data)
    end

  end
end
