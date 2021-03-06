# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/capture'
require 'artifice'
require 'uri'
require 'test_helpers/sandbox'
require 'spout/commands/update'

module ApplicationTests
  # Test to assure that spout gem can display update command correctly.
  class UpdateTest < SandboxTest
    include TestHelpers::Capture

    def setup
      build_app
    end

    def teardown
      teardown_app
    end

    def rubygems_app_update_available
      proc do
        [
          200,
          { 'Content-Type' => 'application/json' },
          [{ 'name' => 'spout', 'version' => 'NEW_VERSION_NUMBER' }.to_json]
        ]
      end
    end

    def rubygems_not_available
      proc do
        raise Net::ReadTimeout
      end
    end

    def rubygems_app_version_up_to_date
      proc do
        [
          200,
          { 'Content-Type' => 'application/json' },
          [{ 'name' => 'spout', 'version' => Spout::VERSION::STRING }.to_json]
        ]
      end
    end

    def test_update_newer_version_available
      Artifice.activate_with(rubygems_app_update_available) do
        output, _error = util_capture do
          Dir.chdir(app_path) { Spout.launch ['update'] }
        end
        assert_match 'A newer version (vNEW_VERSION_NUMBER) is available!', output
      end
    end

    def test_update_server_not_online
      Artifice.activate_with(rubygems_not_available) do
        output, _error = util_capture do
          Dir.chdir(app_path) { Spout.launch ['update'] }
        end
        assert_match 'Unable to connect to RubyGems.org. Please try again later.', output
      end
    end

    def test_update_version_up_to_date
      Artifice.activate_with(rubygems_app_version_up_to_date) do
        output, _error = util_capture do
          Dir.chdir(app_path) { Spout.launch ['update'] }
        end
        assert_match 'The spout gem is', output
        assert_match 'up-to-date', output
      end
    end
  end
end
