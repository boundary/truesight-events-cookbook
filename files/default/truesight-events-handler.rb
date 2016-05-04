require 'chef'
require 'chef/handler'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class TrueSightEvents < Chef::Handler
  API_URI = "https://api.truesight.bmc.com/v1/events"

  def initialize(options)
    @email = options[:email]
    @api_token = options[:api_token]
  end

  def get(type)
    case type
    when :success
      return {
        :title => "Successful Chef run",
        :tags => ["chef-success"],
        :status => "CLOSED",
        :severity => "INFO",
        :message => "Successful Chef run for #{run_status.node.name} (#{run_status.node.ipaddress})",
        :properties => {
          :updatedResourceCount => run_status.updated_resources.length.to_i,
        }
      }
    when :failed
      return {
        :title => "Failed Chef run",
        :tags => ["chef-failure"],
        :status => "OPEN",
        :severity => "ERROR",
        :message => "Failed Chef run for #{run_status.node.name} (#{run_status.node.ipaddress})",
        :properties => {
          :exception => run_status.formatted_exception,
          :backtrace => backtrace.join(", ")
        }
      }
    else
      return nil
    end
  end

  def report
    if run_status.success?
      event = get(:success)
      Chef::Log.info("Chef run suceeded with #{run_status.updated_resources.length.to_i} changes @ #{run_status.end_time}; creating TrueSight Event")
    elsif run_status.failed?
      event = get(:failed)
      Chef::Log.error("Chef run failed @ #{run_status.end_time}, creating TrueSight Event")
      Chef::Log.error("#{run_status.formatted_exception}")
    end

    event[:properties].update({
      :run_list=>run_status.node.run_list.to_s, 
      :roles=>run_status.node.roles.join(", ")
    })
    create(event)
  end

  def create(event)
    event.update({
      :source => {
        :ref => run_status.node.name,
        :type => "host"
      }
    })

    event[:fingerprintFields] ||= []
    event[:fingerprintFields] << "eventKey"
    event[:properties].update({
      :eventKey => "chef-run",
      :startTime => run_status.start_time.to_i,
      :endTime => run_status.end_time.to_i,
    })

    uri = URI.parse(API_URI)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    begin
      timeout(10) do
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = event.to_json
        req.basic_auth @email, @api_token
        req.add_field "Content-Type", "application/json"

        res = http.request(req)

        unless bad_response?(:post, uri.request_uri, res)
          Chef::Log.info("Created a TrueSight Event @ #{res["location"]}")
          res["location"]
        end
      end
    rescue Timeout::Error
      Chef::Log.error("Timed out while attempting to create TrueSight Event")
    end
  end

  def bad_response?(method, url, response)
    case response
    when Net::HTTPSuccess
      false
    else
      true
      Chef::Log.error("Got a #{response.code} for #{method} to #{url}")
      Chef::Log.error(response.body)
    end
  end
end