require 'erb'
require 'fileutils'

module Wirp
  class PortForwarding
    SYSCTL                = "/usr/sbin/sysctl"
    IPFW                  = "/sbin/ipfw"

		def initialize(stdout)
			@stdout = stdout
			@enabled = false
		end

    attr_reader :enabled
    alias_method :enabled?, :enabled

    def start
      @stdout.puts "Starting port forwarding..."

      system(SYSCTL, "-w", "net.inet.ip.scopedroute=0") 
      system(IPFW, "add", "5", "fwd", "127.0.0.1,8080", "tcp", "from", "not", "me", "to", "any", "80")
      system(IPFW, "add", "5", "fwd", "127.0.0.1,8443", "tcp", "from", "not", "me", "to", "any", "443")
      @enabled = true
    end

    def stop
      @stdout.puts "Stopping port forwarding..."

      system(SYSCTL, "-w", "net.inet.ip.scopedroute=1") 
      system(IPFW, "delete", "5")
      @enabled = false
    end
	end
end

