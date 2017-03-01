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

require "tomlrb"

module OAuth2c
  module CLI
    class Config
      UnknownConfigError = Class.new(StandardError)

      def initialize(path)
        @path = path
        load_config
      end

      def hydrate_options(name, options)
        cfg = @config[name]
        raise UnknownConfig, "unknown config for #{name}" if cfg.nil?

        options.authz_uri     = cfg["authz_uri"]
        options.token_uri     = cfg["token_uri"]
        options.client_id     = cfg["client_id"]
        options.client_secret = cfg["client_secret"]
        options.redirect_uri  = cfg["redirect_uri"]
        options.strategy    ||= cfg["default_strategy"]
        options.scope       ||= cfg["default_scopes"]
        options
      end

      private

      def load_config
        File.open(@path, File::CREAT|File::RDWR, 0644) do |fp|
          @config = Tomlrb.parse(fp.read)
        end
      end
    end
  end
end
