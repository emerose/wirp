require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'wirp/app'

describe Wirp::App, "#parse_options" do
  it "should print a help message and exit when -h is passed" do
    out = StringIO.new
    app = Wirp::App.new(["-h"], out)
    lambda { app.parse_options }.should raise_error SystemExit
    out.length.should be > 0
  end
end

