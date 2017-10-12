require 'pact/mock_service/cli/custom_thor'
require 'webrick/https'
require 'rack/handler/webrick'
require 'fileutils'
require 'pact/mock_service/server/wait_for_server_up'
require 'pact/mock_service/cli/pidfile'
require 'socket'

module Pact
  module StubService
    class CLI < Pact::MockService::CLI::CustomThor

      desc 'PACT ...', "Start a stub service with the given pact file(s). Note that this is in beta release, and no logic has been added to handle the situation where more than one matching interaction is found for a request. At the moment, an error response will be returned."

      method_option :port, aliases: "-p", desc: "Port on which to run the service"
      method_option :host, aliases: "-h", desc: "Host on which to bind the service", default: 'localhost'
      method_option :log, aliases: "-l", desc: "File to which to log output"
      method_option :cors, aliases: "-o", desc: "Support browser security in tests by responding to OPTIONS requests and adding CORS headers to mocked responses"
      method_option :ssl, desc: "Use a self-signed SSL cert to run the service over HTTPS", type: :boolean, default: false
      method_option :sslcert, desc: "Specify the path to the SSL cert to use when running the service over HTTPS"
      method_option :sslkey, desc: "Specify the path to the SSL key to use when running the service over HTTPS"
      method_option :stub_pactfile_paths, hide: true

      def service(*pactfiles)
        raise Thor::Error.new("Please provide an existing pact file to load") if pactfiles.empty?
        require 'pact/mock_service/run'
        options.stub_pactfile_paths = pactfiles
        opts = Thor::CoreExt::HashWithIndifferentAccess.new
        opts.merge!(options)
        opts[:stub_pactfile_paths] = pactfiles
        opts[:pactfile_write_mode] = 'none'
        MockService::Run.(opts)
      end

      desc 'version', "Show the pact-stub-service gem version"

      def version
        require 'pact/mock_service/version.rb'
        puts Pact::MockService::VERSION
      end

      default_task :service
    end
  end
end
