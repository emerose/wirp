require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'wirp/network_configuration'

describe Wirp::NetworkConfiguration do
  before do
    @nc = Wirp::NetworkConfiguration.new
  end

  it "should respond to the right things" do
    [:router_addr, :netmask, :network_name, :network_address, 
     :broadcast_address, :first_usable_ip, :last_usable_ip].each do |method|
      @nc.should respond_to(method)
    end
  end
end

