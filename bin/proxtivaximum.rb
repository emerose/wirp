#!/usr/bin/env ruby
#
# PROXTIVAXIMUM!  EXTREME PROXICATION!
#
# warning: extreme proxying ahead.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'proxtivaximum/app'

app = Proxtivaximum::App.new(ARGV)
app.run

