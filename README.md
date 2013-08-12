# Chef IRC Snitch

Chef IRC Snitch is an OpsCode Chef exception handler for notifying
people when a Chef run fails via IRC; providing a link to a private
GitHub Gist containing node information, an exception message, and a
backtrace. The IRC message also includes the node name and its run
list, making it possible to sift/search through logs for a specific
failure. Using GitHub Gists to store failure information provides a
convenient way to share with others.

## Installation

    gem install chef-irc-snitch

## Usage

Append the following to your Chef client configs, usually at `/etc/chef/client.rb`.
Note that the user must already be joined to the channel for this to work.

    # Notify admins via IRC when a Chef run fails
    require "chef-irc-snitch"

    irc_uri = "irc://nick:password@irc.domain.com:6667/#admins"
    enable_ssl = true

    irc_handler = IRCSnitch.new(irc_uri, enable_ssl)

    exception_handlers << irc_handler

If necessary it's possible to have the client join the channel on every chef-client
invocation.  While this isn't efficient it may be necessary in some scenarios.

    join_channel = true
    irc_handler = IRCSnitch.new(irc_uri, enable_ssl, join_channel)

Alternatively, you can use the LWRP (available @
http://community.opscode.com/cookbooks/chef_handler)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
