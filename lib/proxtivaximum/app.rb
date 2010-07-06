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

      # make sure we clean up after ourselves
      at_exit do
        clean_up
      end
    end

    def run
      parse_options
      start_internet_sharing
      start_port_forwarding
      wait_until_done
      clean_up
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

    def start_internet_sharing
      puts "Starting internet sharing..."
      @internet_sharing_on = true
    end

    def stop_internet_sharing
      puts "Stopping internet sharing..."
      @internet_sharing_on = false
    end

    def start_port_forwarding
      puts "Starting port forwarding..."
      @port_forwarding_on = true
    end

    def stop_port_forwarding
      puts "Stopping port forwarding..."
      @port_forwarding_on = false
    end

    def wait_until_done
      puts "Ok, all systems go.  Do your thing and hit return when finished."
      gets
    end

    def clean_up
      if @port_forwarding_on
        stop_port_forwarding
      end

      if @internet_sharing_on
        stop_internet_sharing
      end
    end
  end
end
