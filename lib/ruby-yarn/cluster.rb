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

module RubyYarn

  class Cluster < YarnApiObject

    def info
      url = "#{client.base_url}/cluster"
      client.get(url, Info, 'clusterInfo')
    end

    def haState
      url = "#{client.base_url}/cluster/info"
      client.get(url, Info, 'clusterInfo').haState
    end

    class Info < ApiMash
    end

    def metrics
      url = "#{client.base_url}/cluster/metrics"
      client.get(url, ClusterMetrics, 'clusterMetrics')
    end

    def scheduler
      url = "#{client.base_url}/cluster/scheduler"
      client.get(url, ClusterScheduler, ['scheduler', 'schedulerInfo'])
    end

    def apps(params={})
      valid = [:states, :finalStatus, :user, :queue, :limit,
               :startedTimeBegin, :startedTimeEnd, :finishedTimeBegin,
               :finishedTimeEnd, :applicationTypes, :applicationTags]
      unless (params.keys - valid).empty?
        raise "Invalid args: #{(params.keys - valid).join(',')}. Valid args are #{valid.join(',')}"
      end

      qs = params.empty? ? '' : '?'+params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      url = "#{client.base_url}/cluster/apps#{qs}"
      client.get(url, App, ['apps', 'app'])

    end

    def app(appId)
      url = "#{client.base_url}/cluster/apps/#{appId}"
      client.get(url, App, ['app'])
    end

    def appstatistics(params={})
      valid = [:states, :applicationTypes]
      unless (params.keys - valid).empty?
        raise "Invalid args: #{(params.keys - valid).join(',')}. Valid args are #{valid.join(',')}"
      end

      qs = params.empty? ? '' : '?'+params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      url = "#{client.base_url}/cluster/appstatistics#{qs}"
      client.get(url, AppStat, ['appStatInfo', 'statItem'])
    end

    def nodes(params={})
      valid = [:state, :healthy]
      unless (params.keys - valid).empty?
        raise "Invalid args: #{(params.keys - valid).join(',')}. Valid args are #{valid.join(',')}"
      end

      qs = params.empty? ? '' : '?'+params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      url = "#{client.base_url}/cluster/nodes#{qs}"
      client.get(url, Node, ['nodes', 'node'])
    end

    def node(nodeId)
      url = "#{client.base_url}/cluster/nodes/#{nodeId}"
      client.get(url, Node, ['node'])
    end

    class ClusterMetrics < ApiMash
    end

    class ClusterScheduler < ApiMash
    end

    class App < ApiMash
      def appattempts
        url = "#{client.base_url}/cluster/apps/#{id}/appattempts"
        client.get(url, AppAttempt, ['appAttempts'])
      end
      alias_method :attempts, :appattempts
    end

    class AppAttempt < ApiMash
    end

    class AppStat < ApiMash
    end

    class Node < ApiMash
    end

  end


end

