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

module OAuth2c
  module Cache
    class Store
      Bucket = Struct.new(:access_token, :scope)

      def initialize(backend)
        @backend = backend
      end

      def cached?(key, scope: [])
        cached(key, scope: scope) ? true : false
      end

      def cached(key, scope: [])
        cache = @backend.lookup(key)
        return false if cache.nil?
        return false unless scope.all? { |s| cache.scope.include?(s) }

        if cache.access_token.expires_at >= Time.now
          cache.access_token
        end
      end

      def issue(key, scope:, &block)
        cached = @backend.lookup(key)
        scope  = cached[:scope] | scope if cached

        access_token = block.call(scope)
        @backend.store(key, Bucket.new(access_token, scope))
        access_token
      end
    end
  end
end
