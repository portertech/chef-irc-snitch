require 'rubygems'
require 'chef'
require 'chef/handler'
require 'uri'
require 'json'
require 'rest-client'
require 'carrier-pigeon'

class IRCSnitch < Chef::Handler

  def initialize(irc_uri, github_token, ssl = false)
    @irc_uri = irc_uri
    @github_token = github_token
    @ssl = ssl
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

      gist_url = nil

      payload = {
        "files" => {
          "#{node.name}-#{@timestamp.to_i.to_s}" => {
            "content" => message
          },
        },
        "public" => false,
        "description" => "Chef run failed on #{node.name} @ #{@timestamp}"
      }
      begin
        timeout(10) do
          res = RestClient.post("https://api.github.com/gists", JSON.generate(payload), {:accept => :json, :authorization => "token #{@github_token}"})
          gist_url = JSON.parse(res)["html_url"]
          Chef::Log.info("Created a GitHub Gist @ https://gist.github.com/#{gist_url}")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to create a GitHub Gist")
      end

      ip_address = (node.has_key? :ec2) ? node.ec2.public_ipv4 : node.ipaddress
      message = "Chef run failed on #{node.name} : #{ip_address} : #{node.roles.join(", ")} : #{gist_url}"
      Chef::Log.info("Sending via IRC: '#{message}'")

      begin
        timeout(10) do
          CarrierPigeon.send(:uri => @irc_uri, :message => message, :join => true, :ssl => @ssl)
          Chef::Log.info("Informed chefs via IRC '#{message}'")
        end
      rescue Timeout::Error
        Chef::Log.error("Timed out while attempting to message Chefs via IRC")
      end
    end
  end

end
