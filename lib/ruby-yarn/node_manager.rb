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

  class NodeManager < YarnApiObject

    def info
      url = "#{client.base_url}/node/info"
      client.get(url, Info, 'nodeInfo')
    end

    class Info < ApiMash
    end

    def apps
      url = "#{client.base_url}/node/apps"
      client.get(url, App, ['apps', 'app'])
    end

    def app(appId)
      url = "#{client.base_url}/node/apps/#{appId}"
      client.get(url, App, ['app'])
    end

    def containers
      url = "#{client.base_url}/node/containers"
      client.get(url, Container, ['containers', 'container'])
    end

    def container(containerId)
      url = "#{client.base_url}/node/containers/#{containerId}"
      client.get(url, Container, ['container'])
    end

    class App < ApiMash
    end

    class Container < ApiMash
    end

  end

end
