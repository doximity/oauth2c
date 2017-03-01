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

require "logger"
require "optparse"
require "securerandom"

module OAuth2c
  module CLI
    class Runner
      class Options
        attr_accessor(
          :authz_srv,
          :strategy,
          :client_id,
          :client_secret,
          :redirect_uri,
          :scope,
        )

        def initialize(attrs = {})
          attrs.each do |name, value|
            public_send("#{name}=", value)
          end
        end
      end

      def initialize(options)
        @options = options

        @parser = OptionParser.new do |opts|
          opts.banner = "Usage: #{$0} [options] <authz_srv_url> [<strategy> [<strategy_arg>...]]"

          opts.separator <<-EOS

  This is a full blown OAuth2 client built for CLI. It allows for requesting and fetching an
  access token directly from the console. For flows that requires user authorization, a small
  web server is started to be able to receive the callback.

  Examples:

  #{$0} --id CLIENT_ID --secret CLIENT_SECRET https://example.com/oauth authorization_code
  #{$0} --id CLIENT_ID --secret CLIENT_SECRET https://example.com/oauth implicit
  #{$0} --id CLIENT_ID --secret CLIENT_SECRET https://example.com/oauth client_credentials
  #{$0} --id CLIENT_ID --secret CLIENT_SECRET https://example.com/oauth resource_owner_credentials 'USERNAME' 'PASSWORD'

  Options:

          EOS

          opts.on("--id=CLIENT_ID", "The client ID registered with the authorization server.") do |v|
            @options.client_id = v
          end

          opts.on("--secret=CLIENT_SECRET", "The client secret registered with the authorization server.") do |v|
            @options.client_secret = v
          end

          opts.on("-sSCOPE", "--scope=SCOPE", "The comma separated list of scopes to request", "Example: profile,email") do |v|
            @options.scope = v.split(',')
          end

          opts.on("-uREDIRECT_URI", "--redirect-uri=REDIRECT_URI", "The redirect URI to use for the authorization endpoint", "If not specified, the client will spin-up it's own server and use it's URL") do |v|
            @options.redirect_uri = v
          end
        end
      end

      def usage!
        puts @parser.help
        exit 1
      end

      def error!(err)
        STDERR.print "error: #{err}\n\n"
        usage!
      end

      def run!(args)
        strategy_args = parse_args(args)

        agent = OAuth2c::Agent.new(@options.authz_srv, @options.client_id, @options.client_secret)

        namespace = @options.strategy.gsub(/(?:\A|[_])(\w)/) { $1.upcase }
        strategy  = ::OAuth2c::Strategies.const_get(namespace)

        if strategy.const_defined?(:AuthzHandler, false)
          authz_strategy = strategy::AuthzHandler.new

          if authz_strategy.response_type != "token" && !strategy::TokenHandler.respond_to?(:from_authz_callback_params)
            error!(<<-EOS)
  The #{@options.strategy} strategy requires exchanging authorization for token but does not implement from_authz_callback_url.
  Without it, it's impossible to map the authorization callback URL to the token request.
            EOS
          end

          log    = Logger.new(STDOUT)
          server = WebServer.new(7374, log)

          begin
            server.start

            state = SecureRandom.urlsafe_base64(8)
            url   = agent.authz_url(strategy::AuthzHandler.new(*strategy_args), redirect_uri: server.url, scope: @options.scope, state: state)

            uname = `uname`.chop
            case
            when uname == 'Darwin' && system("which open > /dev/null 2>&1")
              system("open '#{url}'")
            when uname == 'Linux' && system("which xdg-open > /dev/null 2>&1")
              system("xdg-open '#{url}'")
            else
              print "\n!! ACTION REQUIRED !!\n\nOpen the following URL in your browser:\n#{url}\n\n"
            end

            callback_url = URI.parse(server.queue.pop)

            if authz_strategy.response_type == "token"
              params = Hash[URI.decode_www_form(callback_url.fragment)]
              token  = AccessToken.new(params)
            else
              params = Hash[URI.decode_www_form(callback_url.query)]
              token  = agent.token(strategy::TokenHandler.from_authz_callback_params(params), redirect_uri: server.url)
            end
          ensure
            server.stop
            puts ""
          end
        else
          token = agent.token(strategy::TokenHandler.new(*strategy_args))
        end

        puts <<-EOS % token.attributes
  Access Token successfully issued:

  access_token: %<access_token>s
    token_type: %<token_type>s
    expires_in: %<expires_in>d
    expires_at: %<expires_at>s
  refresh_token: %<refresh_token>s
  extra_params: %<extra_params>p

        EOS
      end

      private

      def parse_args(args)
        args = args.dup
        @parser.parse!(args)

        if args.length < 2
          error!("invalid number of arguments")
        end

        @options.authz_srv = args.shift
        @options.strategy  = args.shift

        if @options.client_id.nil? || @options.client_id == ""
          error!("client ID not informed")
        end

        if @options.client_secret.nil? || @options.client_secret == ""
          error!("client secret not informed")
        end

        args
      end
    end
  end
end
