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

require "thread"

module OAuth2c
  module Cache
    module Backends
      class InMemoryLRU
        def initialize(max_size)
          @max_size = max_size
          @store = {}
          @mtx = Mutex.new
        end

        def lookup(key)
          @mtx.synchronize do
            return nil unless @store.has_key?(key)
            @store[key] = @store.delete(key)
          end
        end

        def store(key, bucket)
          @mtx.synchronize do
            @store[key] = bucket

            if @store.size > @max_size
              @store.shift
            end
          end
        end
      end
    end
  end
end
