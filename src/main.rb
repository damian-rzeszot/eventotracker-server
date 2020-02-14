require "sinatra"
require "sinatra/json"

class Whatever
  def self.generate(object)
    JSON.pretty_generate(object)
  end
end

set :json_encoder, Whatever


get "/apps/:app/events.json" do |app|
  events = Dir["apps/#{app}/event-*"].map do |directory|
    id = directory.split("-").last.to_i

    event = {
      "id": id
    }
    .merge(JSON.parse(File.read(File.join(directory, "meta.json"))))

    if event["open"] != false
      event["config"] = uri("/apps/#{app}/#{id}/config.json")
    end

    event
  end

  json({
    "header": {
      "image": "http://app.evento.co.nz/ironman_home/App_header_750x400.png"
    },
    "events": events
  })
end



get "/apps/:app/:id/config.json" do |app_name, event_id|

  content = {
    "entrants_list": {
      "url": uri("/apps/#{app_name}/#{event_id}/entrants.json")
    },
    "entrants_details": {
      "url": uri("/apps/#{app_name}/#{event_id}/details.json")
    }
  }
  .merge(JSON.parse(File.read(File.join("apps", app_name, "event-#{event_id}", "config.json"))))


  json(content)
end


# http://localhost:4567/apps/sample/3/config.json
