#
# mysql_health - a service for monitoring MySQL and exposing its health through an HTTP interface
# Copyright (C) 2012 Erik Osterman <e@osterman.com>
# 
# This file is part of mysql_health.
# 
# mysql_health is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# mysql_health is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with mysql_health.  If not, see <http://www.gnu.org/licenses/>.
#
require 'logger'
require 'optparse'

module MysqlHealth
  @@health = nil
  @@log = nil
  
  def self.health 
    @@health
  end

  def self.health=(health)
    @@health = health
  end

  def self.log
    @@log
  end

  def self.log=(log)
    @@log = log
  end

  class ArgumentException < Exception; end
  class CommandLine
    attr_accessor :options
    def initialize
      @options = {}
      @options[:server] = {}
      @options[:check] = {}
      @options[:log] = {}

      begin
        @optparse = OptionParser.new do |opts|
          opts.banner = "Usage: #{$0} options"
          #
          # Health check
          #
          @options[:check][:master] = false
          opts.on( '--check:master', 'Master health check') do
            @options[:check][:master] = true
          end

          @options[:check][:slave] = false
          opts.on( '--check:slave', 'Slave health check') do |host|
            @options[:check][:slave] = true
          end

          @options[:check][:allow_overlapping] = false
          opts.on( '--check:allow-overlapping', "Allow overlapping health checks (default: #{@options[:check][:allow_overlapping]})") do
            @options[:check][:allow_overlapping] = true
          end

          @options[:check][:interval] = '10s'
          opts.on( '--check:interval INTERVAL', "Check health every INTERVAL (default: #{@options[:check][:interval]})") do |interval|
            @options[:check][:interval] = interval.to_s
          end

          @options[:check][:delay] = '0s'
          opts.on( '--check:delay DELAY', "Delay health checks for INTERVAL (default: #{@options[:check][:delay]})") do |delay|
            @options[:check][:delay] = interval.to_s
          end

          @options[:check][:dsn] ||= "DBI:Mysql:mysql:localhost"
          opts.on( '--check:dsn DSN', "MySQL DSN (default: #{@options[:check][:dsn]})") do |dsn|
            @options[:check][:dsn] = dsn.to_s
          end

          @options[:check][:username] ||= "root"
          opts.on( '--check:username USERNAME', "MySQL Username (default: #{@options[:check][:username]})") do |username|
            @options[:check][:username] = username.to_s
          end

          @options[:check][:password] ||= ""
          opts.on( '--check:password PASSWORD', "MySQL Password (default: #{@options[:check][:password]})") do |password|
            @options[:check][:password] = interval.to_s
          end

          # Server
          @options[:server][:listen] = '0.0.0.0'
          opts.on( '-l', '--server:listen ADDR', "Server listen address (default: #{@options[:server][:listen]})") do |addr|
            @options[:server][:addr] = host.to_s
          end

          @options[:server][:port] = 3305
          opts.on( '-p', '--server:port PORT', "Server listen port (default: #{@options[:server][:port]})") do |port|
            @options[:server][:port] = port.to_i
          end

          @options[:server][:daemonize] = false
          opts.on( '-d', '--server:daemonize', "Daemonize the process (default: #{@options[:server][:daemonize]})") do
            @options[:server][:daemonize] = true
          end

          @options[:server][:pid_file] = false
          opts.on('-P', '--server:pid-file PID-FILE', "Pid-File to save the process id (default: #{@options[:server][:pid_file]})") do |pid_file|
            @options[:server][:pid_file] = pid_file
          end
 

          #
          # Logging
          #

          @options[:log][:level] = Logger::INFO
          opts.on( '--log:level LEVEL', 'Logging level (default: INFO)' ) do|level|
            @options[:log][:level] = Logger.const_get level.upcase
          end

          @options[:log][:file] = STDERR
          opts.on( '--log:file FILE', 'Write logs to FILE (default: STDERR)' ) do|file|
            @options[:log][:file] = File.open(file, File::WRONLY | File::APPEND | File::CREAT)
          end

          @options[:log][:age] = 7
          opts.on( '--log:age DAYS', "Rotate logs after DAYS pass (default: #{@options[:log][:age]})" ) do|days|
            @options[:log][:age] = days.to_i
          end

          @options[:log][:size] = 1024*1024*10
          opts.on( '--log:size SIZE', "Rotate logs after the grow past SIZE bytes (default: #{@options[:log][:size]})" ) do |size|
            @options[:log][:size] = size.to_i
          end
        end
        @optparse.parse!

        raise ArgumentException.new("No action specified") if @options[:check][:master] == false && @options[:check][:slave] == false
        @log = Logger.new(@options[:log][:file], @options[:log][:age], @options[:log][:size])
        @log.level = @options[:log][:level]

        daemonize if @options[:server][:daemonize]
        write_pid_file if @options[:server][:pid_file]

        MysqlHealth.log = @log
        MysqlHealth.health = Health.new(@options[:check])

      rescue ArgumentException => e
        puts e.message
        puts @optparse
        exit 1
      end
    end

    def daemonize
      # Become a daemon
      if RUBY_VERSION < "1.9"
        exit if fork
        Process.setsid
        exit if fork
        Dir.chdir "/" 
        STDIN.reopen "/dev/null"
        STDOUT.reopen "/dev/null", "a" 
        STDERR.reopen "/dev/null", "a" 
      else
        Process.daemon
      end 
    end

    def write_pid_file
      @log.debug("writing pid file #{@options[:server][:pid_file]}")
      File.open(@options[:server][:pid_file], 'w') do |f| 
        f.write(Process.pid)
      end
    end

    def execute
      begin
        ::EM.run do
          ::EM.start_server @options[:server][:listen], @options[:server][:port], Server
        end
      rescue ArgumentException => e
        @log.fatal(e.message)
      rescue Interrupt => e
        @log.info("exiting...")
      rescue Exception => e
        @log.fatal(e.message + e.backtrace.join("\n"))
      end
    end
  end
end
