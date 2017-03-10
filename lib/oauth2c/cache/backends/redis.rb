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

require "json"

module OAuth2c
  module Cache
    module Backends
      class Redis
        using Refinements

        def initialize(redis, namespace = nil)
          @redis = redis
          @namespace = namespace
        end

        def lookup(key)
          access_token_data, scope_data = @redis.mget("#{fq_key(key)}:access_token", "#{fq_key(key)}:scope")
          return if access_token_data.nil? || scope_data.nil?

          access_token = AccessToken.new(**JSON.load(access_token_data).symbolize_keys)
          Store::Bucket.new(access_token, JSON.load(scope_data))
        end

        def store(key, bucket)
          @redis.mset(
            "#{fq_key(key)}:access_token", JSON.dump(bucket.access_token.attributes),
            "#{fq_key(key)}:scope", JSON.dump(bucket.scope),
          )
        end

        private

        def fq_key(key)
          @namespace ? "#{@namespace}:#{key}" : key
        end
      end
    end
  end
end
