redis_opts = { url: 'redis://localhost:6379/12' }

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end