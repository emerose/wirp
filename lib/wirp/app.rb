require 'optparse'
require 'wirp/network_configuration'
require 'wirp/internet_sharing'
require 'wirp/port_forwarding'

module Wirp
  class App
    VERSION = '0.0.1'

    attr_reader :verbose, :internet_sharing, :port_forwarding, :network_config

    def initialize(arguments, stdout)
      @arguments        = arguments
      @stdout           = stdout

      @network_config   = NetworkConfiguration.new
      @internet_sharing = InternetSharing.new(@stdout)
      @port_forwarding  = PortForwarding.new(@stdout)

      # Set defaults
      @verbose          = 0

      # make sure we clean up after ourselves
      at_exit do
        clean_up
      end
    end

    def run
      parse_options
      @internet_sharing.start(@network_config)
      @port_forwarding.start
      wait_until_done
      clean_up
    end

    def parse_options
      opts = OptionParser.new 
      opts.banner = "Wirp version #{VERSION} EXTREME!\nUsage: wirp [options]"

      opts.on('-h', '--help', "Print this help message") { @stdout.puts opts ; exit 0 }
      opts.on('-v', '--verbose', "Enable more verbose output (May be used multiple times)") { @verbose+=1 }  
      opts.on('--ip IP', "IP to use for router (Default: #{@network_config.router_addr})") { |ip| @network_config.router_addr = ip }  
      opts.on('--netmask MASK', "Netmask to use for captive network (Default: #{@network_config.netmask})") { |m| @network_config.netmask = m }  
      opts.on('--name NAME', "Name to use for wireless network (Default: #{@network_config.network_name})") { |n| @network_config.network_name = n }  

      opts.parse!(@arguments) rescue return false
    end

    def wait_until_done
      @stdout.puts "Ok, all systems go.  Do your thing and hit return when finished."
      gets
    end

    def clean_up
      if @port_forwarding.enabled?
        @port_forwarding.stop
      end

      if @internet_sharing.enabled?
        @internet_sharing.stop
      end
    end
  end
end
