require 'spec_helper'
require 'zendesk_apps_tools/server'

describe ZendeskAppsTools::Server do
  settings_file = 'spec/fixture/test_app/settings.yml'

  before do
    app.set :port, 4567
    app.set :root, 'spec/fixture/test_app'
    app.set :parameters, {}
    app.set :manifest, [{name: "text_field", type: "text"}]
    app.set :config, settings_file
    app.set :app_id, 0
  end

  it "returns 404 for root directory" do
    get '/'
    expect(last_response.status).to eq(404)
  end

  describe 'GET /apps.js' do
    # Not testing the content, because that's covered in ZendeskAppsSupport's tests
    it "returns a successful response" do
      get '/app.js'
      expect(last_response).to be_ok
    end
  end

  describe "GET /logo.png" do
    it "returns a sucesful response" do
      get '/logo.png'
      expect(last_response).to be_ok
    end
  end

  describe "GET /api/v2/apps/0.json" do
    it "returns an app JSON" do
      get '/api/v2/apps/0.json'
      expect(last_response).to be_ok
      expect(last_response.body).to eq({
        id: "0",
        name: "ABC",
        author_name: "John Smith",
        author_email: "john@example.com",
        author_url: "",
        small_icon: "http://localhost:4567/0/logo-small.png",
        large_icon: "http://localhost:4567/0/logo.png",
        framework_version: "0.5",
        version: "1.0.0",
        parameters: [{name: "text_field", kind: "text", required: false, default_value: nil, secure: false}]
      }.to_json)
    end
  end

  describe "GET /api/v2/apps/installations/0.json" do
    it "returns an installation JSON" do
      get '/api/v2/apps/installations/0.json'
      expect(last_response).to be_ok
      expect(last_response.body).to eq({
        id: "0",
        app_id: "0",
        settings: {
          title: "ABC"
        }
      }.to_json)
    end
  end

  describe 'PUT /api/v2/apps/installations/0.json' do
    context 'with a valid settings JSON' do
      before do
        File.delete settings_file if File.exists? settings_file
      end

      after do
        File.delete settings_file
      end

      it "saves settings JSON" do
        put '/api/v2/apps/installations/0.json', {text_field: 'a new value'}.to_json, {
          'HTTP_ACCEPT' => 'application/json',
          'CONTENT_TYPE' => 'application/json'
        }

        expect(last_response).to be_ok
        expect(File.exists? settings_file).to be(true)
        expect(last_response.body).to eq({
          id: "0",
          app_id: "0",
          settings: {
            title: "ABC",
            text_field: "a new value"
          }
        }.to_json)
      end
    end

    context 'with an invalid setting JSON' do
      it "returns an error" do
        put '/api/v2/apps/installations/0.json', '{"invalid: true}', {
          'HTTP_ACCEPT' => 'application/json',
          'CONTENT_TYPE' => 'application/json'
        }

        expect(last_response.status).to be(500)
      end
    end
  end
end
