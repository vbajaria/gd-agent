class GdApiTailInput < Fluent::TailInput
  Fluent::Plugin.register_input('in-gd-api', self)

  # Override the 'configure_parser(conf)' method.
  # You can get config parameters in this method.
  def configure_parser(conf)
    @time_format = '%d/%b/%Y:%H:%M:%S %Z'
    @line_regexp = Regexp.new('^(?<ip>\d+\.\d+\.\d+\.\d+)\s+\S+\s+\S+\s+\[(?<log_time>\S+\s\S+)\]\s"GET\s(?<url>.*?)\sHTTP\/\d+\.\d+"\s(?<response_code>\d+)\s(?<req_size>\d+)')
    @datamart_regexp = Regexp.new('^.*datamart=(?<datamart>\w+)&.*')
    @dimensions_regexp = Regexp.new('^.*dimensions=(?<dimensions>\w+)&.*')
    @metrics_regexp = Regexp.new('^.*metrics=(?<metrics>\w+)&.*')
    @start_date_regexp = Regexp.new('^.*start_date=(?<start_date>\d+)&.*')
    @end_date_regexp = Regexp.new('^.*end_date=(?<end_date>\d+)&.*')
  end

  # Override the 'parse_line(line)' method that returns the time and record.
  # This example method assumes the following log format:
  #   %Y-%m-%d %H:%M:%S\tkey1\tvalue1\tkey2\tvalue2...
  #   %Y-%m-%d %H:%M:%S\tkey1\tvalue1\tkey2\tvalue2...
  #   ...
  def parse_line(line)
    
    begin
      parsed_line = @line_regexp.match(line)
      time = Time.strptime(parsed_line[:log_time], @time_format).to_i
      datamart = @datamart_regexp.match(parsed_line[:url])
      dimensions = @dimensions_regexp.match(parsed_line[:url])
      metrics = @metrics_regexp.match(parsed_line[:url])
      start_date = @start_date_regexp.match(parsed_line[:url])
      end_date = @end_date_regexp.match(parsed_line[:url])

      record = {
        ip: parsed_line[:ip],
        datamart: datamart[:datamart],
        dimensions: dimensions[:dimensions],
        metrics: metrics[:metrics],
        start_date: start_date[:start_date],
        end_date: end_date[:end_date],
        status: parsed_line[:response_code],
        size: parsed_line[:req_size],
      }

      return time, record
    rescue => e
      $log.warn "error #{e} in parsing line #{line}" 
    end
  end
end
