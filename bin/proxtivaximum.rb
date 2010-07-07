#!/usr/bin/env ruby
#
# Wirp!
#
# warning: extreme proxying ahead.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'wirp/app'

app = Wirp::App.new(ARGV)
app.run

