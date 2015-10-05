require 'sinatra/base'
require 'zendesk_apps_support/package'
include ZendeskAppsTools::PackageHelper

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :public_folder, proc { "#{settings.root}/assets" }
    last_mtime = Time.new(0)

    get '/app.js' do
      content_type 'text/javascript'

      if File.exists? settings.config
        curr_mtime = File.stat(settings.config).mtime
        if curr_mtime > last_mtime
          settings_helper = ZendeskAppsTools::Settings.new
          settings.parameters = settings_helper.get_settings_from_file(settings.config, settings.manifest)
          last_mtime = curr_mtime
        end
      end

      ZendeskAppsSupport::Package.new(settings.root).readified_js(nil, settings.app_id, "http://localhost:#{settings.port}/", settings.parameters, params['locale'])
    end

    get "/api/v2/apps/:app_id.json" do |app_id|
      content_type 'application/json'
      cors_headers

      manifest_json = manifest settings.root

      parameters = (manifest_json[:parameters] || []).map do | parameter |
        {
          name: parameter[:name],
          kind: parameter[:type] || 'text',
          required: parameter[:required] || false,
          default_value: parameter[:default] || nil,
          secure: parameter[:secure] || false
        }
      end

      manifest_author = manifest_json[:author] || {}
      {
        id: app_id,
        name: manifest_json[:name] || "Public App",
        author_name: manifest_author[:name] || "Zendesk",
        author_email: manifest_author[:email] || "apps@zendesk.com",
        author_url: manifest_author[:url] || "",
        small_icon: "http://localhost:#{settings.port}/#{app_id}/logo-small.png",
        large_icon: "http://localhost:#{settings.port}/#{app_id}/logo.png",
        framework_version: manifest_json[:frameworkVersion] || "1.0",
        version: manifest_json[:version] || "1.0.0",
        parameters: parameters
      }.to_json
    end

    get "/api/v2/apps/installations/:install_id.json" do |install_id|
      content_type 'application/json'
      cors_headers

      manifest_json = manifest settings.root

      if File.exists? settings.config
        settings_helper = ZendeskAppsTools::Settings.new
        app_settings = settings_helper.get_settings_from_file(settings.config, settings.manifest)
      else
        app_settings = settings.parameters
      end

      {
        id: install_id,
        app_id: install_id,
        settings: {
          'title' => manifest_json[:name] || "Public App"
        }.merge(app_settings)
      }.to_json
    end

    put "/api/v2/apps/installations/:install_id.json" do |install_id|
      content_type 'application/json'
      cors_headers
      begin
        data = JSON.parse request.body.read
      rescue => err
        puts "Error parsing reqeust JSON body: #{err.message}"
        return 500
      end

      manifest_json = manifest settings.root

      if File.exists?(settings.config)
        settings_helper = ZendeskAppsTools::Settings.new
        app_settings = settings_helper.get_settings_from_file(settings.config, settings.manifest)
      else
        app_settings = settings.parameters
      end

      app_settings_string = settings.config =~ /\.json$/ ? JSON.generate(app_settings.merge(data)) : YAML.dump(app_settings.merge(data))

      File.open(settings.config, 'w') {|f| f.write(app_settings_string) }

      settings_helper = ZendeskAppsTools::Settings.new
      app_settings = settings_helper.get_settings_from_file(settings.config, settings.manifest)

      {
        id: install_id,
        app_id: install_id,
        settings: {
          'title' => manifest_json[:name] || "Public App"
        }.merge(app_settings)
      }.to_json
    end

    private

    def cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end
  end
end
