# frozen_string_literal: true
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/api_connection'
require 'zendesk_apps_tools/deploy'
require 'zendesk_apps_tools/directory'
require 'zendesk_apps_tools/translate'
require 'zendesk_apps_tools/bump'

module ZendeskAppsTools
  module CommandHelpers
    include ZendeskAppsTools::Common
    include ZendeskAppsTools::APIConnection
    include ZendeskAppsTools::Deploy
    include ZendeskAppsTools::Directory

    def self.included(base)
      base.extend(ClassMethods)
    end

    def cache
      @cache ||= begin
        require 'zendesk_apps_tools/cache'
        Cache.new(options)
      end
    end

    def setup_path(path)
      @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path

    def zip(app_package, archive_path)
      require 'zip'

      Zip::File.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          relative_path = file.relative_path
          path = relative_path
          say_status 'package', "adding #{path}"

          # resolve symlink to source path
          if File.symlink? file.absolute_path
            path = File.expand_path(File.readlink(file.absolute_path), File.dirname(file.absolute_path))
          end
          if file.to_s == 'app.scss'
            relative_path = relative_path.sub 'app.scss', 'app.css'
          end
          zipfile.add(relative_path, app_dir.join(path).to_s)
        end
      end
    end
  end
end
