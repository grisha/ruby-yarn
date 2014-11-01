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

  class History < YarnApiObject

    def info
      url = "#{client.base_url}/info"
      client.get(url, 'Info', 'instoryInfo')
    end

    class Info < ApiMash
    end

    def mapreduce_jobs(params={})
      valid = [:user, :state, :queue, :limit,
               :startedTimeBegin, :startedTimeEnd, :finishedTimeBegin,
               :finishedTimeEnd]
      unless (params.keys - valid).empty?
        raise "Invalid args: #{(params.keys - valid).join(',')}. Valid args are #{valid.join(',')}"
      end

      qs = params.empty? ? '' : '?'+params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
      url = "#{client.base_url}/mapreduce/jobs#{qs}"
      client.get(url, MapReduce::Job, ['jobs', 'job'])
    end

    def mapreduce_job(jobId)
      url = "#{client.base_url}/mapreduce/jobs/#{jobId}"
      client.get(url, MapReduce::Job, ['job'])
    end

  end

end
