require "logger"
require "optparse"
require "securerandom"
require "webrick"
require "rack"
require "thread"

module OAuth2
  module Client
    class CLI
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
        @threads = []

        args = args.dup
        @parser.parse!(args)

        if args.length < 1
          error!("invalid number of arguments")
        end

        @options.authz_srv = args.shift
        @options.strategy  = args.shift if args.any?

        if @options.client_id.nil? || @options.client_id == ""
          error!("client ID not informed")
        end

        if @options.client_secret.nil? || @options.client_secret == ""
          error!("client secret not informed")
        end

        agent = OAuth2::Client::Agent.new(@options.authz_srv, @options.client_id, @options.client_secret)

        namespace = @options.strategy.gsub(/(?:\A|[_])(\w)/) { $1.upcase }
        strategy  = ::OAuth2::Client::Strategies.const_get(namespace)

        token = if strategy::TokenHandler.respond_to?(:from_authz_callback)
                  token_with_authz_flow(agent, strategy)
                else
                  agent.token(strategy::TokenHandler.new(*args))
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

        if @threads.any?
          puts "Shutting down..."
          @threads.each(&:join)
        end
      ensure
        @threads.clear
      end

      private

      def token_with_authz_flow(agent, strategy)
        buf   = StringIO.new
        log   = Logger.new(buf)
        state = SecureRandom.urlsafe_base64(8)
        queue = Queue.new
        redirect_uri = "http://localhost:7374"

        begin
          url = agent.authz_url(strategy::AuthzHandler.new, redirect_uri: redirect_uri, scope: @options.scope, state: state)
          start_server(log, queue)
          `open "#{url}"`

          params = queue.pop

          agent.token(strategy::TokenHandler.from_authz_callback(params), redirect_uri: redirect_uri)
        rescue
          puts buf
          raise
        ensure
          @threads << Thread.new { Rack::Handler::WEBrick.shutdown }
        end
      end

      def start_server(log, queue)
        Thread.new do
          app = Proc.new do |env|
            req = Rack::Request.new(env)
            queue << req.GET
            ['200', {'Content-Type' => 'text/html'}, ['Authorization received, you may close this browser']]
          end

          Rack::Handler::WEBrick.run(app, Port: 7374, Logger: log)
        end
      end
    end
  end
end
