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

set :json_encode, PrettyJSONEncoder

# Generate json repsonses

def cache(key)
  $cache ||= {}
  $cache[key] ||= yield
end

def content(*args)
  path = File.join(settings.root, "apps", *args)
  content = File.read(path)
  template = ERB.new(content)
  yaml = YAML.load(template.result(binding))
  yaml.to_json
end

def cached_content(*args)
  cache(args) do
    content(args)
  end
end

# Endpoints

get "/:app_name/events.json" do |app_name|
  @app_name = app_name

  cached_content(app_name, "events.yaml.erb")
end

get "/:app_name/:event_id/config.json" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "config.yaml.erb")
end

get "/:app_name/:event_id/entrants.json" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  cached_content(app_name, event_id, "entrants.yaml.erb")
end
