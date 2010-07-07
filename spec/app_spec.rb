require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'wirp/app'

describe Wirp::App, "#parse_options" do
  it "should print a help message and exit when -h is passed" do
    out = StringIO.new
    app = Wirp::App.new(["-h"], out)
    lambda { app.parse_options }.should raise_error SystemExit
    out.length.should be > 0
  end

  it "should increase the verbosity every time -v is passed" do
    out = StringIO.new

    normal = Wirp::App.new([], out)
    normal.parse_options
    normal.verbose.should == 0

    onev = Wirp::App.new(["-v"], out)
    onev.parse_options
    onev.verbose.should == 1

    twov = Wirp::App.new(["-v", "-v"], out)
    twov.parse_options
    twov.verbose.should == 2
  end

  it "should allow setting router IP from the command line" do
    out = StringIO.new
    app = Wirp::App.new(["--ip", "5.6.7.8"], out)
    app.parse_options
    app.network_config.router_addr.should == "5.6.7.8"
  end

  it "should allow setting netmask from the command line" do
    out = StringIO.new
    app = Wirp::App.new(["--netmask", "255.0.0.0"], out)
    app.parse_options
    app.network_config.netmask.should == "255.0.0.0"
  end

  it "should allow setting network name from the command line" do
    out = StringIO.new
    app = Wirp::App.new(["--name", "WOOOHOOO"], out)
    app.parse_options
    app.network_config.network_name.should == "WOOOHOOO"
  end
end

