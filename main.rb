require "sinatra"
require "sinatra/json"
require "sinatra/reloader" if development?
require "erb"
require "yaml"

# Prettify output

class PrettyJSONEncoder
  def self.encode(object)
    JSON.pretty_generate(object)
  end
end

set :json_encode, PrettyJSONEncoder

# Generate json repsonses

def content(*args)
  path = File.join(settings.root, "apps", *args)
  content = File.read(path)
  template = ERB.new(content)
  yaml = YAML.load(template.result(binding))

  yaml.to_json
end

# Events endpoint

get "/apps/:app_name/events.json" do |app_name|
  @app_name = app_name
  content app_name, "events.yaml.erb"
end

get "/apps/:app_name/:event_id/entrants.json" do |app_name, event_id|
  @app_name = app_name
  @event_id = event_id

  # content app_name, event_id, ""
end
