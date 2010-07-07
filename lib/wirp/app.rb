require 'optparse'
require 'wirp/network_configuration'
require 'wirp/internet_sharing'

module Wirp
  class App
    VERSION               = '0.0.1'
    SYSCTL                = "/usr/sbin/sysctl"
    IPFW                  = "/sbin/ipfw"

    attr_reader :verbose, :router_ip, :netmask, :internet_sharing, :port_forwarding_on, :network_name
    attr_reader :network_config

    def initialize(arguments, stdout)
      @arguments = arguments
      @stdout    = stdout

      @network_config   = NetworkConfiguration.new
      @internet_sharing = InternetSharing.new(@stdout)

      # Set defaults
      @verbose             = 0
      @preserve            = {}
      @port_forwarding_on  = false

      # make sure we clean up after ourselves
      at_exit do
        clean_up
      end
    end

    def run
      parse_options
      @internet_sharing.start(@network_config)
      start_port_forwarding
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

    def start_port_forwarding
      @stdout.puts "Starting port forwarding..."

      system(SYSCTL, "-w", "net.inet.ip.scopedroute=0") 
      system(IPFW, "add", "5", "fwd", "127.0.0.1,8080", "tcp", "from", "not", "me", "to", "any", "80")
      system(IPFW, "add", "5", "fwd", "127.0.0.1,8443", "tcp", "from", "not", "me", "to", "any", "443")
      @port_forwarding_on = true
    end

    def stop_port_forwarding
      @stdout.puts "Stopping port forwarding..."

      system(SYSCTL, "-w", "net.inet.ip.scopedroute=1") 
      system(IPFW, "delete", "5")
      @port_forwarding_on = false
    end

    def wait_until_done
      @stdout.puts "Ok, all systems go.  Do your thing and hit return when finished."
      gets
    end

    def clean_up
      if @port_forwarding_on
        stop_port_forwarding
      end

      if @internet_sharing.enabled?
        @internet_sharing.stop
      end
    end
  end
end
