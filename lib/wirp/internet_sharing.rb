require 'erb'
require 'fileutils'

module Wirp
  class InternetSharing
    BOOTPD_PLIST          = "/etc/bootpd.plist"
    BOOTPD_PLIST_TEMPLATE = File.join(File.dirname(__FILE__), 'resources', 'bootpd.plist.erb')
    NATD_PLIST            = "/Library/Preferences/SystemConfiguration/com.apple.nat.plist"
    NATD_PLIST_TEMPLATE   = File.join(File.dirname(__FILE__), 'resources', 'com.apple.nat.plist.erb')
    INTERNET_SHARING_BIN  = "/usr/libexec/InternetSharing"

    def initialize(stdout)
      @stdout = stdout
      @enabled = false
    end

    attr_reader :enabled
    alias_method :enabled?, :enabled

    def start(netcfg)
      @stdout.puts "Starting internet sharing..."

      { BOOTPD_PLIST => BOOTPD_PLIST_TEMPLATE, 
        NATD_PLIST   => NATD_PLIST_TEMPLATE }.each_pair do |file, template|

        if File.exist?(file)
          FileUtils.rm(file + ".wirp-bak", :force => true)
          FileUtils.mv(file, file + ".wirp-bak")
        end

        erb = ERB.new(File.read(template))
        File.open(file, "w") do |f|
          f.write erb.result netcfg.get_binding
        end
      end

      @internet_sharing_pid = fork
      if @internet_sharing_pid.nil?
        # in child
        exec INTERNET_SHARING_BIN
      end

      @enabled = true
    end

    def stop
      @stdout.puts "Stopping internet sharing..."

      raise "No child!?" unless @internet_sharing_pid

      Process.kill(15, @internet_sharing_pid)
      [BOOTPD_PLIST, NATD_PLIST].each do |file|
        FileUtils.rm(file)
        FileUtils.mv(file + ".wirp-bak", file) if File.exist?(file + ".wirp-bak")
      end

      @enabled = false
    end
  end
end
