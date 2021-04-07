require "sinatra"
require "sinatra/json"
require "erb"
require "yaml"
require 'faker'

if development?
  require "byebug"
  require "sinatra/reloader"
end

# JSON Body

class Sinatra::Request
  def json
    @json ||= Proc.new {
      body.rewind
      Sinatra::IndifferentHash[JSON.parse(body.read)]
    }.call
  end
end

# Prettify output

class PrettyJSONEncoder
  def self.encode(object)
    JSON.pretty_generate(object)
  end
end

set :bind, '0.0.0.0'
set :json_encoder, PrettyJSONEncoder

# Generate responses

def content(*args)
  path = File.join(settings.root, "apps", *args)
  content = File.read(path)
  template = ERB.new(content)
  object = YAML.load(template.result(binding))

  json object
end

def cache(key)
  return yield if settings.development?

  $cache ||= {}
  $cache[key] ||= yield
end

def cached_content(*args)
  cache(args) do
    content(args)
  end
end

# Endpoints

get "/:app_name/events" do |app_name|
  @app_name = app_name

  content(app_name, "events.yaml.erb")
end

get "/:app_name/:event_id/config" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "config.yaml.erb")
end

get "/:app_name/:event_id/entrants" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "entrants.yaml.erb")
end

get "/:app_name/:event_id/feed" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "feed.yaml.erb")
end

get "/:app_name/:event_id/pages" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "pages.yaml.erb")
end

get "/:app_name/:event_id/entrants/:entrant_id/details" do |app_name, event_id, entrant_id|
  @app_name = app_name
  @event_id = event_id
  @entrant_id = entrant_id

  content(app_name, event_id, "details.yaml.erb")
end

post "/:app_name/:event_id/predictions" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  @tracks = request.json[:tracks]

  content(app_name, event_id, "predictions.yaml.erb")
end

get "/:app_name/:event_id/schedule" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  content(app_name, event_id, "schedule.yaml.erb")
end
