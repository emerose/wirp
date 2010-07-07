require 'ipaddr'

module Wirp
  class NetworkConfiguration
    def initialize
      @router_addr  = "10.123.123.1"
      @netmask      = "255.255.255.0"
      @network_name = "INTENSE AWESOMEITUDE"
    end

    attr_accessor :router_addr, :netmask, :network_name

    def network_address
      IPAddr.new(router_addr).mask(netmask).to_range.first.to_s
    end

    def broadcast_address
      IPAddr.new(router_addr).mask(netmask).to_range.last.to_s
    end

    def first_usable_ip
      ip = IPAddr.new(router_addr)
      return IPAddr.new(ip.to_i + 1, ip.family).to_s
    end

    def last_usable_ip
      # IPAddr is teh suck.
      ip = IPAddr.new(router_ip)
      num = ip.mask(netmask).to_range.last.to_i
      return IPAddr.new(num - 1, ip.family).to_s
    end
  end
end
