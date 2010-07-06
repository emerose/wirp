require 'optparse'
require 'erb'
require 'ipaddr'

module Proxtivaximum
  class App
    VERSION = '0.0.1'
    DEFAULT_CAPTIVE_NETWORK="10.0.2.1/24"

    attr_reader :options

    def initialize(arguments)
      @arguments = arguments

      # Set defaults
      @options = {}
      @options[:verbose] = false
      @options[:quiet]   = false
      @options[:network] = DEFAULT_CAPTIVE_NETWORK
    end

    def run
      parse_options
    end

    protected

    def parse_options
      opts = OptionParser.new 
      opts.on('-v', '--version')    { output_version ; exit 0 }
      opts.on('-h', '--help')       { output_help }
      opts.on('-V', '--verbose')    { @options.verbose = true }  

      opts.parse!(@arguments) rescue return false
    end

    def output_help
      puts version
      puts <<-HELP
      WOOO!  PROXYTASTIC!
      HELP
    end

    def version
      "Proxtivaximum version #{VERSION} EXTREME!"
    end
  end
end
