require "sinatra"
require "sinatra/json"
require "sinatra/reloader" if development?
require "erb"
require "yaml"
require 'faker'

# Prettify output

class PrettyJSONEncoder
  def self.encode(object)
    JSON.pretty_generate(object)
  end
end

set :bind, '0.0.0.0'
set :json_encoder, PrettyJSONEncoder

# Generate responses

def cache(key)
  return yield if settings.development?

  $cache ||= {}
  $cache[key] ||= yield
end

def content(*args)
  path = File.join(settings.root, "apps", *args)
  content = File.read(path)
  template = ERB.new(content)
  object = YAML.load(template.result(binding))

  json object
end

def cached_content(*args)
  cache(args) do
    content(args)
  end
end

# Endpoints

get "/:app_name/events" do |app_name|
  @app_name = app_name

  cached_content(app_name, "events.yaml.erb")
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

get "/:app_name/:event_id/entrants/:entrant_id/details" do |app_name, event_id, entrant_id|
  @app_name = app_name
  @event_id = event_id
  @entrant_id = entrant_id

  cached_content(app_name, event_id, "details.yaml.erb")
end
