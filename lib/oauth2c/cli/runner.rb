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
      BANNER = "Usage: #{$0} [options] <authz_srv_url> [<strategy> [<strategy_arg>...]]"

      DESCRIPTION = <<-EOS

This is a full blown OAuth2 client built for CLI. It allows for requesting and fetching an
access token directly from the console. For flows that requires user authorization, a small
web server is started to be able to receive the callback.

Configuration:

  In order to use this tool, you need to add the configuration for each authorization server
  you want to use, as follow:

  # ~/.config/oauth2c/oauth2c.toml
  [google]
  authz_uri        = "https://accounts.google.com/o/oauth2/auth"
  token_uri        = "https://accounts.google.com/o/oauth2/token"
  client_id        = "YOUR_CLIENT_ID"
  client_secret    = "YOUR_CLIENT_SECRET"
  default_strategy = "authorization_code"
  default_scopes   = ["https://www.googleapis.com/auth/userinfo.email"]

Options:

      EOS

      def initialize(config, args)
        @config        = config
        @args          = args
        @options       = Options.new
        @strategy_args = []

        @parser = OptionParser.new do |opts|
          opts.banner = BANNER
          opts.separator(DESCRIPTION)

          opts.on(
            "-tSTRATEGY",
            "--strategy=STRATEGY",
            "The strategy (grant type) to use",
          ) do |v|
            @options.strategy = v
          end

          opts.on(
            "-sSCOPE",
            "--scope=SCOPE",
            "The comma separated list of scopes to request",
            "Example: profile,email",
          ) do |v|
            @options.scope = v.split(',')
          end
        end
      end

      def run!
        parse_args!

        agent = OAuth2c::Agent.new(@options.authz_uri, @options.token_uri, @options.client_id, @options.client_secret)

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
            url   = agent.authz_url(strategy::AuthzHandler.new(*@strategy_args), redirect_uri: server.url, scope: @options.scope, state: state)

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
            query_params = Hash[URI.decode_www_form(callback_url.query)]

            if query_params["state"] != state
              fail!("invalid state")
            end

            if query_params["error"]
              raise Error.new(query_params["error"], query_params["error_description"])
            elsif authz_strategy.response_type == "token"
              params = Hash[URI.decode_www_form(callback_url.fragment.to_s)]
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
          token = agent.token(strategy::TokenHandler.new(*@strategy_args))
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
      rescue Error => e
        fail!(e.message)
      end

      private

      def usage!
        puts @parser.help
        exit 1
      end

      def error!(err)
        STDERR.print "error: #{err}\n\n"
        puts @parser.help
        exit 1
      end

      def fail!(err)
        STDERR.print "error: #{err}\n\n"
        exit 1
      end

      def parse_args!
        args = @args.dup
        @parser.parse!(args)

        if args.length < 1
          error!("invalid number of arguments")
        end

        name = args.shift

        begin
          @config.hydrate_options(name, @options)
        rescue Config::UnknownConfigError
          error!("unknown config #{name}")
        end

        if @options.strategy.nil?
          error!("strategy not specified")
        end

        if @options.authz_uri.nil? || @options.token_uri.nil?
          error!("authorization server's urls not configured")
        end

        @strategy_args = args
      end
    end
  end
end
