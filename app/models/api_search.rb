class ApiSearch
  cattr_reader :redis
  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)

  CACHE_EXPIRATION_IN_SECONDS = 5 * 60

  def self.search(options)
    format = options[:format] =~ /xml/i ? :xml : :json
    index = options[:index] == "odie" ? :odie : :bing
    if index == :odie
      options[:page] = options[:page] + 1 if options[:page]
      search = OdieSearch.new(options)
    else
      search = WebSearch.new(options)
    end
    api_cache_key = "API:#{options[:affiliate].name}:#{index}:#{search.cache_key}:#{format}"
    if cached = @@redis.get(api_cache_key) rescue nil
      cached
    else
      search.run
      result = format == :xml ? search.to_xml : search.to_json
      @@redis.setex(api_cache_key, CACHE_EXPIRATION_IN_SECONDS, result) rescue nil
      result
    end
  end
end
