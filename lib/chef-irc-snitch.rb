require 'rubygems'
require 'chef'
require 'chef/handler'
require 'net/http'
require 'uri'
require 'json'
require 'shout-bot'

class IRCSnitch < Chef::Handler

  def initialize(irc_uri, github_user, github_token, ssl = false)
    @irc_uri = irc_uri
    @github_user = github_user
    @github_token = github_token
    @ssl = ssl
  end

  def report
    Chef::Log.error("Chef run failed @ #{Time.now.getutc}, snitchin' to chefs via IRC")

    gist = "#{run_status.formatted_exception}\n"
    gist << Array(backtrace).join("\n")

    max_attempts = 2
    gist_id = nil

    begin
      timeout(8) do
        res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
          "files[#{node.name}-#{Time.now.to_i.to_s}]" => gist,
          "login" => @github_user,
          "token" => @github_token,
          "description" => "Chef run failed on #{node.name} @ #{Time.now.getutc}",
          "public" => false
        })
        gist_id = JSON.parse(res.body)["gists"].first["repo"]
      end
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to create a GitHub Gist, retrying ...")
      max_attempts -= 1
      retry if max_attempts > 0
    end

    Chef::Log.info("Created a GitHub Gist @ https://gist.github.com/#{gist_id}")

    max_attempts = 2
    ip_address = (node.has_key? :ec2) ? node.ec2.public_ipv4 : node.ipaddress
    message = "Chef run failed on #{node.name} (#{ip_address}) : https://gist.github.com/#{gist_id}"

    begin
      timeout(8) do
        ShoutBot.shout(@irc_uri, nil, @ssl) do |channel|
          channel.say message
          Chef::Log.info("Informed chefs via IRC : #{message}")
        end
      end
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to message Chefs via IRC, retrying ...")
      max_attempts -= 1
      retry if max_attempts > 0
    end
  end

end
