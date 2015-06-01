#
# Copyright (C) 2014 Gregory Trubetskoy
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#

require 'rest-client'
require 'json'
require 'hashie'

module RubyYarn

  class ApiMash < Hashie::Mash
    attr_reader :client
    def initialize(hash, client=nil)
      @client = client
      super(hash)
    end
  end

  class YarnApiObject
    attr_reader :client
    def initialize(base_url)
      @client = YarnRestApiClient.new(base_url)
    end
  end

  class YarnRestApiClient
    attr_reader :base_url
    attr_reader :connections

    def initialize(base_urls)
      @connections = base_urls.split(",")
      if @connections.length == 1 
        @base_url = @connections[0]

        ### assume connected when only one server given
        @connected = true
      else
        @base_url = nil
      end
    end

    def connected?
      @connected || false
    end

    def base_url
      connect! unless connected?
      @base_url 
    end
    
    def connect!
      return if connected?
   
      zz = @connections.map do |cx|
        begin
          RestClient.get(cx + "/cluster", accept: :json) do |response,request,result| 
            # raises exception if response is not 200-206. Also follows redirects
            response.return!
            raise StandbyRM unless response.headers[:refresh].nil? 
          end

          cx
        rescue StandbyRM, Errno::ECONNREFUSED, RestClient::Exception
          nil
        end
      end

      ### should only be one after compact, but just in case...
      @base_url = zz.compact.sample

      raise Errno::ECONNREFUSED if @base_url.nil? || @base_url.empty?
      @connected = true
    end


    class StandbyRM < Exception
    end

    def get(url, klass, key=nil)
      retried = false
      connect! unless connected?
      begin
        RestClient.get(url, :accept=>:json) do |response, request, result, &blk|
          if response.headers[:refresh]
            # TODO We detect that this is a Standy RM by catching
            # the refresh header it sends, feels like a bit of a hack -
            # is there a better way to do this?
            refresh_url = URI(response.headers[:refresh].split(';').last.split('=',2).last)
            new_base_uri = URI(base_url)
            new_base_uri.host = refresh_url.host
            new_base_uri.port = refresh_url.port
            @base_url = new_base_uri.to_s
            url = refresh_url.to_s
            raise StandbyRM
          end
          case response.code
          when 200
            j = JSON.parse(response.body)
            begin
              # key can be an array to fetch deeper nested hash elements
              # http://stackoverflow.com/questions/18251454/access-nested-hash-element-specified-by-an-array-of-keys
              subset = key.nil? ? j : [key].flatten.inject(j, :fetch)
            rescue NoMethodError => e
              return [] if e.message =~ /nil:NilClass|nil object/ # node/apps can return nil
              raise
            rescue KeyError => e
              return [] # it's not always there for some things
              raise
            end

            # opportunity for custom reformat block
            subset = yield subset if block_given?

            if subset.is_a? Array
              # apply class to each element
              h = subset.map do |el|
                klass.new(el, self)
              end
            else
              h = klass.new(subset, self)
            end
            return h
          else
            response.return!(request, result, &blk)
          end
        end
      rescue StandbyRM
        raise "Both RMs in Standby? Bailing." if retried
        puts "WARNING: This is a Standby RM, switching base_url to #{base_url} and retrying"
        retried = true
        retry
      end
    end
  end

end
