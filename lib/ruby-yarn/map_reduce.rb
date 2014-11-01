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

  class MapReduce < YarnApiObject

    def info
      url = "#{client.base_url}/mapreduce/info"
      client.get(url, Info, 'info')
    end

    def jobs
      url = "#{client.base_url}/mapreduce/jobs"
      client.get(url, Job, ['jobs', 'job'])
    end

    def job(jobId)
      url = "#{client.base_url}/mapreduce/jobs/#{jobId}"
      client.get(url, Job, ['job'])
    end

    class Info < ApiMash
    end

    class Job < ApiMash
      def jobattempts
        url = "#{client.base_url}/mapreduce/jobs/#{id}/jobattempts"
        client.get(url, Attempt, ['jobAttempts', 'jobAttempt'])
      end
      alias_method :attempts, :jobattempts

      def counters
        url = "#{client.base_url}/mapreduce/jobs/#{id}/counters"
        client.get(url, CounterGroup, ['jobCounters', 'counterGroup'])
      end

      def conf
        url = "#{client.base_url}/mapreduce/jobs/#{id}/conf"
        client.get(url, Conf, ['conf']) do |conf|
          properties = {path: conf['path']}
          conf['property'].each do |p|
            properties[p['name']] = Conf::Property.new(p['name'], p['value'], p['source'])
          end
          properties
        end
      end

      def tasks(params={})
        valid = [:type]
        unless (params.keys - valid).empty?
          raise "Invalid args: #{(params.keys - valid).join(',')}. Valid args are #{valid.join(',')}"
        end

        qs = params.empty? ? '' : '?'+params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join("&")
        url = "#{client.base_url}/mapreduce/jobs/#{id}/tasks#{qs}"
        client.get(url, Task, ['tasks', 'task']) do |tasks|
          tasks.each do |task|
            task['jobId'] = id
          end
        end
      end

      def task(taskId)
        url = "#{client.base_url}/mapreduce/jobs/#{id}/tasks/#{taskId}"
        client.get(url, Task, ['task']) do |task|
          task['jobId'] = id
          task
        end
      end

      class CounterGroup < ApiMash
      end

      class Attempt < ApiMash
      end

      class Conf < ApiMash
        class Property
          attr_reader :name, :value, :source
          def initialize(name, value, source)
            @name, @value, @source = name, value, source
          end
          alias_method :to_s, :value
        end
      end

      class Task < ApiMash
        def counters
          url = "#{client.base_url}/mapreduce/jobs/#{jobId}/tasks/#{id}/counters"
          client.get(url, TaskCounterGroup, ['jobTaskCounters', 'taskCounterGroup'])
        end
        def attempts
          url = "#{client.base_url}/mapreduce/jobs/#{jobId}/tasks/#{id}/attempts"
          client.get(url, TaskAttempt, ['taskAttempts', 'taskAttempt']) do |atts|
            atts.each do |att|
              att['jobId'] = jobId
              att['taskId'] = id
            end
          end
        end
        def attempt(attemptId)
          url = "#{client.base_url}/mapreduce/jobs/#{jobId}/tasks/#{id}/attempts/#{attemptId}"
          client.get(url, TaskAttempt, ['taskAttempt']) do |att|
            att['jobId'] = jobId
            att['taskId'] = id
            att
          end
        end
      end

      class TaskCounterGroup < ApiMash
      end

      class TaskAttempt < ApiMash
        def counters
          url = "#{client.base_url}/mapreduce/jobs/#{jobId}/tasks/#{taskId}/attempts/#{id}/counters"
          client.get(url, TaskAttemptCounterGroup, ['jobTaskAttemptCounters', 'taskAttemptCounterGroup'])
        end

        class TaskAttemptCounterGroup < ApiMash
        end

      end

    end


  end

end
