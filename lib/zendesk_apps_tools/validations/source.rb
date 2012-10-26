require 'jshintrb'

module ZendeskAppsTools
  module Validations
    module Source

      LINTER_OPTIONS = {
        # enforcing options:
        :noarg => true,
        :undef => true,

        # relaxing options:
        :eqnull => true,
        :laxcomma => true,

        # predefined globals:
        :predef =>  %w(
            _ console services helpers alert json base64
            clearinterval cleartimeout setinterval settimeout
          )
      }.freeze

      class <<self
        def call(package)
          source = package.files.find { |f| f.relative_path == 'app.js' }

          return [ ValidationError.new(:missing_source) ] unless source && source.exists?

          jshint_errors = linter.lint(source.read)
          if jshint_errors.any?
            [ JSHintValidationError.new(source.relative_path, jshint_errors) ]
          else
            []
          end
        end

        private

        def linter
          Jshintrb::Lint.new(LINTER_OPTIONS)
        end

      end
    end
  end
end
