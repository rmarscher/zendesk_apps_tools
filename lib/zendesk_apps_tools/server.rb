require 'sinatra/base'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :public_folder, proc { "#{settings.root}/assets" }

    get '/app.js' do
      content_type 'text/javascript'
      ZendeskAppsSupport::Package.new(settings.root).readified_js(nil, 0, "http://localhost:#{settings.port}/", settings.parameters)
    end

    get "/spec_helper.js" do
      content_type 'text/javascript'
      send_file File.expand_path(File.join(File.dirname(__FILE__), "app_spec_helper.js"))
    end

  end
end
