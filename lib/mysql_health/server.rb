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
require 'json'
require 'eventmachine'
require 'eventmachine_httpserver'
require 'evma_httpserver/response'
require 'forwardable'

module MysqlHealth
  class Server < ::EM::Connection
    include ::EM::HttpServer

    def post_init
      super
      no_environment_strings
    end

    def http_response(data)
       MysqlHealth.log.debug("http_response")
      response = EventMachine::DelegatedHttpResponse.new(self)
      if data.nil?
        response.status = '500 Server Error'
        response.content = "Empty call to http_response\n"
      else
        data.each_pair do |k,v|
          MysqlHealth.log.debug("#{k}=#{v}")
          if k == :content_type
            response.send(k, v)
          else
            response.send("#{k}=".to_sym, v)
          end
        end
      end
      response
    end

    def process_http_request
      response = nil
      begin
        case @http_path_info
        when '/master_status'
          response = http_response(MysqlHealth.health.master_status)
        when '/slave_status'
          response = http_response(MysqlHealth.health.slave_status)
        else
          response = http_response({:status => '501 Not Implemented'})
        end
      rescue Exception => e
        response = http_response({:status => '500 Server Error', :content => e.message + "\n" + e.backtrace.join("\n")})
      end
      response.send_response
    end
  end
end
