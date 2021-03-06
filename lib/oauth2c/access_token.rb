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

require "time"

module OAuth2c
  class AccessToken
    attr_reader(
      :access_token,
      :token_type,
      :expires_in,
      :expires_at,
      :refresh_token,
      :extra,
    )

    def initialize(access_token:, token_type:, expires_in:, expires_at: nil, refresh_token: nil, **extra)
      @access_token  = access_token
      @token_type    = token_type
      @expires_in    = Integer(expires_in)
      @refresh_token = refresh_token


      extra.delete(:expires_at)
      @extra = extra

      @expires_at = normalize_time(expires_at) || Time.now + @expires_in
    end

    def attributes
      {
        access_token: @access_token,
        token_type: @token_type,
        expires_in: @expires_in,
        expires_at: @expires_at,
        refresh_token: @refresh_token,
        **@extra,
      }
    end

    def expired?(leeway = 0)
      @expires_at - leeway < Time.now
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      access_token == other.access_token &&
      token_type == other.token_type &&
      expires_in == other.expires_in &&
      refresh_token == other.refresh_token &&
      extra == other.extra
    end

    private

    def normalize_time(time)
      case time
      when Time, NilClass
        time
      when String
        Time.parse(time)
      when Integer
        Time.at(time)
      else
        raise ArgumentError, "invalid time #{time.inspect}"
      end
    end
  end
end
