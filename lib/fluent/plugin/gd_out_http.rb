require 'json'

class Fluent::HTTPOutput < Fluent::Output
  Fluent::Plugin.register_output('gd-agent-http', self)

  def initialize
    super
    require 'net/http'
    require 'uri'
  end

  # This method is called before starting.
  def configure(conf)
    super
    @http_method = if http_methods.include? @http_method.intern
                    @http_method.intern
                  else
                    :get
                  end
    @http_method = conf['http_method']
    unless @http_method
      raise ConfigError, "'http_method' parameter is required on gd-agent-http output"
    end

    @token = conf['token']
    unless @token
      raise ConfigError, "'token' parameter is required on gd-agent-http output"
    end

    @endpoint = conf['endpoint']
    unless @endpoint
      raise ConfigError, "'endpoint' parameter is required on gd-agent-http output"
    end

    @beacon_url = 'http://beacon.grepdata.com/v1/%s?token=%s&q=%s&t=%s'
  end

  # This method is called when starting.
  def start
    super
  end

  # This method is called when shutting down.
  def shutdown
    super
  end

  # This method is called when an event reaches Fluentd.
  # 'es' is a Fluent::EventStream object that includes multiple events.
  # You can use 'es.each {|time,record| ... }' to retrieve events.
  # 'chain' is an object that manages transactions. Call 'chain.next' at
  # appropriate points and rollback if it raises an exception.
  def emit(tag, es, chain)
    es.each do |time,record|
      handle_record(tag, time, record)
    end
    chain.next
  end

  def handle_record(tag, time, record)
    req, uri = create_request(tag, time, record)
    send_request(req, uri)
  end

  def create_request(tag, time, record)
    url = format_url(tag, time, record)
    uri = URI.parse(url)
    if @http_method == 'get'
       req = Net::HTTP.const_get(@http_method.to_s.capitalize).new(uri.path)
    else
      # POST not implemented... 
    end
  end

  def format_url(tag, time, record)
    @beacon_url % [@endpoint, @token, record, time]
  end

end
