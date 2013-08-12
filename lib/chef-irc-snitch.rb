require "rubygems"
require "chef/handler"
require "uri"
require "json"
require "net/https"
require "carrier-pigeon"

class IRCSnitch < Chef::Handler
  def initialize(irc_uri, ssl=false, join=false)
    @irc_uri = irc_uri
    @ssl = ssl
    @join = join
    @timestamp = Time.now.getutc
    @gist_url = nil
  end

  def formatted_run_list
    node.run_list.map { |r| r.type == :role ? r.name : r.to_s }.join(", ")
  end

  def formatted_gist
    ip_address = node.has_key?(:cloud) ? node.cloud.public_ipv4 : node.ipaddress
    node_info = [
      "Node: #{node.name} (#{ip_address})",
      "Run list: #{node.run_list}",
      "All roles: #{node.roles.join(', ')}"
    ].join("\n")
    [
      node_info,
      run_status.formatted_exception,
      Array(backtrace).join("\n")
    ].join("\n\n")
  end

  def create_gist
    begin
      timeout(10) do
        uri = URI.parse("https://api.github.com/gists")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = {
          "description" => "Chef run failed on #{node.name} @ #{@timestamp}",
          "public" => false,
          "files" => {
            "chef_exception.txt" => {
              "content" => formatted_gist
            }
          }
        }.to_json
        response = http.request(request)
        @gist_url = JSON.parse(response.body)["html_url"]
      end
      Chef::Log.info("Created a GitHub Gist @ #{@gist_url}")
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to create a GitHub Gist")
    rescue => error
      Chef::Log.error("Unexpected error while attempting to create a GitHub Gist: #{error}")
    end
  end

  def message_irc
    message = "Chef failed on #{node.name} (#{formatted_run_list}): #{@gist_url}"
    begin
      timeout(10) do
        CarrierPigeon.send(:uri => @irc_uri, :message => message, :ssl => @ssl, :join => @join)
      end
      Chef::Log.info("Informed chefs via IRC: #{message}")
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to message chefs via IRC")
    rescue => error
      Chef::Log.error("Unexpected error while attempting to message chefs via IRC: #{error}")
    end
  end

  def report
    unless STDOUT.tty?
      @timestamp = Time.now.getutc
      Chef::Log.error("Chef run failed @ #{@timestamp}, snitchin' to chefs via IRC")
      create_gist
      unless @gist_url.nil?
        message_irc
      end
    end
  end
end
