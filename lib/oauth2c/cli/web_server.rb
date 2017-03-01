# Copyright 2017 Doximity, Inc. <support@doximity.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "webrick"

module OAuth2c
  module CLI
    class WebServer
      attr_reader :queue

      def initialize(port, log)
        @port   = port
        @queue  = Queue.new
        @server = WEBrick::HTTPServer.new(:Port => port)

        @server.mount_proc("/", &method(:servlet))
      end

      def url
        "http://localhost:#{@port}"
      end

      def start
        Thread.new do
          @server.start
          Rack::Handler::WEBrick.run(build_app, Port: @port, Logger: @log)
        end
      end

      def stop
        @server.shutdown
        sleep 0.1 while @server.status != :Stop
      end

      private

      def servlet(req, res)
        @queue << req.unparsed_uri
        res.status = 200
        res.body   = 'Authorization received, you may close this browser'
      end
    end
  end
end
