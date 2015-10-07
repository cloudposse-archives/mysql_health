# MysqlHealth

MySQL Health is a standalone HTTP server that will respond with a 200 status code when MySQL is operating as expected. 

This script is intended to be used in conjunction with HAProxy "option httpchk" for a TCP load balancer distributing load across mysql servers.

## FAQs

1. If you get the error "caught DBI::InterfaceError exception 'Could not load driver (uninitialized constant MysqlError)'" on OSX, try doing this:
`export DYLD_LIBRARY_PATH="/usr/local/mysql/lib:$DYLD_LIBRARY_PATH"`


## Installation

Add this line to your application's Gemfile:

    gem 'mysql_health'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql_health

## Usage

    Usage: mysql_health options
            --check:master               Master health check
            --check:slave                Slave health check
            --check:allow-overlapping    Allow overlapping health checks (default: false)
            --check:interval INTERVAL    Check health every INTERVAL (default: 10s)
            --check:delay DELAY          Delay health checks for INTERVAL (default: 0s)
            --check:dsn DSN              MySQL DSN (default: DBI:Mysql:mysql:localhost)
            --check:username USERNAME    MySQL Username (default: root)
            --check:password PASSWORD    MySQL Password (default: )
        -l, --server:listen ADDR         Server listen address (default: 0.0.0.0)
        -p, --server:port PORT           Server listen port (default: 3305)
        -d, --server:daemonize           Daemonize the process (default: false)
        -P, --server:pid-file PID-FILE   Pid-File to save the process id (default: false)
            --log:level LEVEL            Logging level (default: INFO)
            --log:file FILE              Write logs to FILE (default: STDERR)
            --log:age DAYS               Rotate logs after DAYS pass (default: 7)
            --log:size SIZE              Rotate logs after the grow past SIZE bytes (default: 10485760)

## Examples

Start the server on port 1234 and check the status of the slave every 30 seconds:

    mysql_health --check:slave --check:interval 30 --server:port 1234

Start the server on port 1234 and check the status of the master every 30 seconds:

    mysql_health --check:master --check:interval 30 --server:port 1234

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
