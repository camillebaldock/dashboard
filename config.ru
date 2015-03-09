require 'dashing'
require 'redis-objects'

redis_uri = URI.parse(ENV["REDISTOGO_URL"])
Redis.current = Redis.new(:host => redis_uri.host,
                          :port => redis_uri.port,
                          :password => redis_uri.password)

set :history, Redis::HashKey.new('dashing-hash')

configure do
  set :auth_token, ENV["AUTH_TOKEN"]
  set :default_dashboard, 'home'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
