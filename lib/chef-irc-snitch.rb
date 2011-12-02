require 'rubygems'
require 'chef'
require 'chef/handler'
require 'net/http'
require 'uri'
require 'json'
require 'carrier-pigeon'
require 'pastie-api'

class IRCSnitch < Chef::Handler

  def initialize(irc_uri, github_user, github_token, irc_channel_password, type, ssl = false)
    @irc_uri = irc_uri
    @github_user = github_user
    @github_token = github_token
    @channel_password = irc_channel_password
    @ssl = ssl
    @type = type
    @timestamp = Time.now.getutc
  end

  def report
    message = "#{run_status.formatted_exception}\n"
    message << Array(backtrace).join("\n")

    if STDOUT.tty?
      Chef::Log.error("Chef run failed @ #{@timestamp}")
      puts message
    else
      Chef::Log.error("Chef run failed @ #{@timestamp}, snitchin' to chefs via IRC")

      gist_id = nil

      if @type == "gist"
        begin
          timeout(10) do
            res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
              "files[#{node.name}-#{@timestamp.to_i.to_s}]" => message,
              "login" => @github_user,
              "token" => @github_token,
              "description" => "Chef run failed on #{node.name} @ #{@timestamp}",
              "public" => false
            })
            gist_id = JSON.parse(res.body)["gists"].first["repo"]
            Chef::Log.info("Created a GitHub Gist @ https://gist.github.com/#{gist_id}")
	    ip_address = (node.has_key? :ec2) ? node.ec2.public_ipv4 : node.ipaddress
            message = "Chef run failed on #{node.name} : #{ip_address} : #{node.roles.join(", ")} : #{gist_url}"
          end
        rescue Timeout::Error
          Chef::Log.error("Timed out while attempting to create a GitHub Gist")
        end
      elsif @type == "pastie"
        begin
          timeout(10) do
            p = Pastie.create(message)
            Chef::Log.info("Created a Pastie @ URL: #{p.link}")
            ip_address = (node.has_key? :ec2) ? node.ec2.public_ipv4 : node.ipaddress
            message = "Chef run failed on #{node.name} | #{ip_address} | Roles: #{node.roles.join(", ")} | URL: #{p.link}"
          end
        rescue Timeout::Error
          Chef::Log.error("Timed out while attempting to create a new pastie")
        end
      end

      begin
        timeout(10) do
	  CarrierPigeon.send(:uri => @irc_uri, :channel_password => @channel_password, :message => message, :join => true, :ssl => @ssl)
          Chef::Log.info("Informed chefs via IRC '#{message}'")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to message Chefs via IRC")
      end
    end
  end

end
