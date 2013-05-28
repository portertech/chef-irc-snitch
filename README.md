# Chef IRC Snitch

Chef IRC Snitch is an OpsCode Chef exception handler for notifying
people when a Chef run fails via IRC; providing a link to a GitHub
Gist containing node information, an exception message, and a
backtrace.


## Installation

    gem install chef-irc-snitch

## Usage

Append the following to your Chef client configs, usually at `/etc/chef/client.rb`

    # Notify admins via IRC when a Chef run fails
    require "chef-irc-snitch"

    irc_uri = "irc://nick:password@irc.domain.com:6667/#admins"
    enable_ssl = true
    join_irc_channel = true
    stdout_report = true

    irc_handler = IRCSnitch.new(irc_uri, enable_ssl, join_irc_channel, stdout_report)

    exception_handlers << irc_handler

Alternatively, you can use the LWRP (available @
http://community.opscode.com/cookbooks/chef_handler)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
