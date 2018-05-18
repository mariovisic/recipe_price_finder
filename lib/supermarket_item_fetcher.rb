require 'net/http'
require 'json'

class SupermarketItemFetcher
  def self.fetch(name)
    uri = URI.parse('https://www.woolworths.com.au/apis/ui/Search/products')
    header = { 'Content-Type' => 'text/json' }
    data = { 'SearchTerm' => name }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json

    response = http.request(request)
  end
end
