require 'optparse'
require 'ipaddr'
require 'erb'
require 'fileutils'

module Proxtivaximum
  class App
    VERSION               = '0.0.1'
    DEFAULT_ROUTER_IP     = "10.123.123.1"
    DEFAULT_NETMASK       = "255.255.255.0"
    DEFAULT_NAME          = "testing_network"
    BOOTPD_PLIST          = "/etc/bootpd.plist"
    BOOTPD_PLIST_TEMPLATE = File.join(File.dirname(__FILE__), 'resources', 'bootpd.plist.erb')
    NATD_PLIST            = "/Library/Preferences/SystemConfiguration/com.apple.nat.plist"
    NATD_PLIST_TEMPLATE   = File.join(File.dirname(__FILE__), 'resources', 'com.apple.nat.plist.erb')

    attr_reader :verbose, :router_ip, :netmask, :internet_sharing_on, :port_forwarding_on, :network_name

    def initialize(arguments)
      @arguments = arguments

      # Set defaults
      @verbose             = 0
      @router_ip           = DEFAULT_ROUTER_IP
      @netmask             = DEFAULT_NETMASK
      @preserve            = {}
      @internet_sharing_on = false
      @port_forwarding_on  = false
      @network_name        = DEFAULT_NAME

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

    def parse_options
      opts = OptionParser.new 
      opts.banner = "Proxtivaximum version #{VERSION} EXTREME!\nUsage: proxtivaximum [options]"

      opts.on('-h', '--help', "Print this help message") { puts opts ; exit 0 }
      opts.on('-v', '--verbose', "Enable more verbose output", "(May be used multiple times)") { @verbose+=1 }  
      opts.on('--ip IP', "IP to use for router", "(Default: #{@router_ip})") { |r| @router_ip = r }  
      opts.on('--netmask MASK', "Netmask to use for captive network", "(Default: #{@netmask})") { |m| @netmask = m }  
      opts.on('--name NAME', "Name to use for wireless network") { |n| @network_name = n }  

      opts.parse!(@arguments) rescue return false
    end

    def start_internet_sharing
      puts "Starting internet sharing..."

      { BOOTPD_PLIST => BOOTPD_PLIST_TEMPLATE, 
        NATD_PLIST   => NATD_PLIST_TEMPLATE }.each_pair do |file, template|

        if File.exist?(file)
          FileUtils.rm(file + ".proxybak", :verbose => (@verbose>0), :force => true)
          FileUtils.mv(file, file + ".proxybak", :verbose => (@verbose>0))
        end

        erb = ERB.new(File.read(template))
        puts "----[ #{file} ]----\n#{erb.result binding}\n----" if verbose > 1
        File.open(file, "w") do |f|
          f.write erb.result binding
        end
      end

      @internet_sharing_pid = fork
      if @internet_sharing_pid.nil?
        # in child
        exec "/usr/libexec/InternetSharing"
      end

      @internet_sharing_on = true
    end

    def stop_internet_sharing
      puts "Stopping internet sharing..."

      Process.kill(15, @internet_sharing_pid)
      [BOOTPD_PLIST, NATD_PLIST].each do |file|
        FileUtils.rm(file, :verbose => (@verbose>0))
        FileUtils.mv(file + ".proxybak", file, :verbose => (@verbose>0)) if File.exist?(file + ".proxybak")
      end

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

    def network_address
      IPAddr.new(router_ip).mask(netmask).to_range.first.to_s
    end

    def broadcast_address
      IPAddr.new(router_ip).mask(netmask).to_range.first.to_s
    end

    def first_usable_ip
      IPAddr.new(router_ip).succ.to_s
    end

    def last_usable_ip
      # IPAddr is teh suck.
      ip = IPAddr.new(router_ip)
      num = ip.mask(netmask).to_range.last.to_i
      return IPAddr.new(num - 1, ip.family).to_s
    end
  end
end
