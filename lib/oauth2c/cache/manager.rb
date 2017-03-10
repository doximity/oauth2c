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

require "forwardable"

module OAuth2c
  module Cache
    class Manager
      extend Forwardable

      def initialize(client, cache_backend)
        @client = client
        @cache  = Cache::Store.new(cache_backend)
      end

      def_delegators :@cache, :cached?, :cached

      def method_missing(name, key, *args, **opts)
        grant = @client.public_send(name, *args, **opts)
        CacheProxy.new(@cache, key, grant)
      end

      class CacheProxy < BasicObject
        def initialize(cache, key, grant)
          @cache = cache
          @key   = key
          @grant = grant
        end

        def method_missing(name, *args)
          @grant.public_send(name, *args)
        end

        def token(*args)
          @cache.issue(@key, scope: @grant.scope) do |new_scope|
            @grant.update_scope(new_scope)
            @grant.token(*args)
          end
        end
      end
    end
  end
end
