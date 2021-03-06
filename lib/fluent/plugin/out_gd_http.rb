class GDHttpOutput < Fluent::Output
  Fluent::Plugin.register_output('out-gd-http', self)

  def initialize
    super
    require 'net/http'
    require 'uri'
    require 'json'
  end

  # This method is called before starting.
  def configure(conf)
    super
    
    @url = conf['url']
    unless @url
      @url = 'https://beacon.grepdata.com/v1'
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

    @beacon_url = '%s/%s' % [@url, @endpoint]
    @query_string = '?token=%s&q=%s&t=%s'
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
    if @http_method == 'get'
      url = @beacon_url + format_query_string(tag, time, record)
    end

    uri = URI.parse(URI.escape(url))
    $log.info "#{uri.path} #{uri.request_uri}"
    req = Net::HTTP.const_get(@http_method.to_s.capitalize).new(uri.request_uri)

    if @http_method == 'post'
      set_body(req, format_query_string(tag, time, record))
    end

    return req, uri
  end
 
  def send_request(req, uri)
    begin
      res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    rescue IOError, EOFError, SystemCallError
      $log.warn "Net::HTTP.#{req.method.capitalize} raises exception: #{$!.class}, '#{$!.message}'"
    end

    unless res and res.is_a?(Net::HTTPSuccess)
      $log.warn "failed to #{req.method} #{uri} (#{res.code} #{res.message} #{res.body})"
    end
  end

  def format_query_string(tag, time, record)
    if time.is_a?(Fixnum)
      @query_string % [@token, JSON.dump(record), time * 1000]
    else
      @query_string % [@token, JSON.dump(record), (time.to_time.to_f * 1000.0).to_i]
    end
  end

  def format_url()
    @beacon_url % [@endpoint]
  end

  def set_body(req, formatted_query_string)
    req.body = formatted_query_string
    req['Content-Type'] = 'application/x-www-form-urlencoded'
  end
end
