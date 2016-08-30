#

# Copyright:: Copyright 2016, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "license_scout/net_fetcher"

require "pathname"

module LicenseScout
  class Overrides

    class OverrideLicenseSet

      attr_reader :license_locations

      def initialize(license_locations)
        @license_locations = license_locations || []
      end

      def empty?
        license_locations.empty?
      end

      def resolve_locations(dependency_root_dir)
        license_locations.map do |license_location|
          if NetFetcher.remote?(license_location)
            NetFetcher.cache(license_location)
          else
            normalize_and_verify_path(license_location, dependency_root_dir)
          end
        end
      end

      def normalize_and_verify_path(license_location, dependency_root_dir)
        full_path = File.expand_path(license_location, dependency_root_dir)
        if File.exists?(full_path)
          full_path
        else
          raise Exceptions::InvalidOverride, "Provided license file path '#{license_location}' can not be found under detected dependency path '#{dependency_root_dir}'."
        end
      end

    end

    attr_reader :override_rules

    def initialize(&rules)
      @override_rules = {}
      instance_eval(&rules) if block_given?

      default_overrides
    end

    def override_license(dependency_manager, dependency_name, &rule)
      override_rules[dependency_manager] ||= {}
      override_rules[dependency_manager][dependency_name] = rule
    end

    def license_for(dependency_manager, dependency_name, dependency_version)
      license_data = license_data_for(dependency_manager, dependency_name, dependency_version)
      license_data && license_data[:license]
    end

    def license_files_for(dependency_manager, dependency_name, dependency_version)
      license_data = license_data_for(dependency_manager, dependency_name, dependency_version)
      OverrideLicenseSet.new(license_data && license_data[:license_files])
    end

    def have_override_for?(dependency_manager, dependency_name, dependency_version)
      override_rules.key?(dependency_manager) && override_rules[dependency_manager].key?(dependency_name)
    end

    private

    def license_data_for(dependency_manager, dependency_name, dependency_version)
      return nil unless have_override_for?(dependency_manager, dependency_name, dependency_version)
      override_rules[dependency_manager][dependency_name].call(dependency_version)
    end

    def default_overrides
      # Default overrides for ruby_bundler dependency manager.
      [
        ["debug_inspector", "MIT", ["README.md"]],
        ["inifile", "MIT", ["README.md"]],
        ["syslog-logger", "MIT", ["README.rdoc"]],
        ["httpclient", "Ruby", ["README.md"]],
        ["little-plugger", "MIT", ["README.rdoc"]],
        ["logging", "MIT", ["README.md"]],
        ["coderay", nil, ["README_INDEX.rdoc"]],
        ["multipart-post", "MIT", ["README.md"]],
        ["erubis", "MIT", nil],
        ["binding_of_caller", "MIT", nil],
        ["method_source", "MIT", nil],
        ["pry-remote", "MIT", nil],
        ["pry-stack_explorer", "MIT", nil],
        ["plist", "MIT", nil],
        ["proxifier", "MIT", nil],
        ["mixlib-shellout", "Apache-2.0", nil],
        ["mixlib-log", "Apache-2.0", nil],
        ["uuidtools", "Apache-2.0", nil],
        ["cheffish", "Apache-2.0", nil],
        ["chef-provisioning", "Apache-2.0", nil],
        ["chef-provisioning-aws", "Apache-2.0", nil],
        ["chef-rewind", "MIT", nil],
        ["ubuntu_ami", "Apache-2.0", nil],
        ["net-telnet", "Ruby", nil],
        ["netrc", "MIT", nil],
        ["oc-chef-pedant", "Apache-2.0", nil],
        ["rake", "MIT", nil],
        ["rspec", "MIT", nil],
        ["yajl-ruby", "MIT", nil],
        ["bunny", "MIT", nil],
        ["em-http-request", "MIT", nil],
        ["sequel", "MIT", nil],
        ["reel", "MIT", nil],
        ["spork", "MIT", nil],
        ["rack-test", "MIT", nil],
        ["moneta", "MIT", nil],
        ["mixlib-authentication", "Apache-2.0", nil],
        ["mixlib-cli", "Apache-2.0", nil],
        ["ohai", "Apache-2.0", nil],
        ["chef", "Apache-2.0", nil],
        ["ipaddress", "MIT", nil],
        ["systemu", "BSD-2-Clause", nil],
        ["pry", "MIT", nil],
        ["puma", "BSD-3-Clause", nil],
        ["rb-inotify", "MIT", nil],
        ["chef-web-core", "Apache-2.0", nil],
        ["knife-opc", "Apache-2.0", nil],
        ["highline", "Ruby", ["LICENSE"]],
        # Overrides that require file fetching from internet
        ["sfl", "Ruby", ["https://raw.githubusercontent.com/ujihisa/spawn-for-legacy/master/LICENCE.md"]],
        ["json_pure", nil, ["https://raw.githubusercontent.com/flori/json/master/README.md"]],
        ["aws-sdk-core", nil, ["https://raw.githubusercontent.com/aws/aws-sdk-ruby/master/README.md"]],
        ["aws-sdk-resources", nil, ["https://raw.githubusercontent.com/aws/aws-sdk-ruby/master/README.md"]],
        ["aws-sdk", nil, ["https://raw.githubusercontent.com/aws/aws-sdk-ruby/master/README.md"]],
        ["fuzzyurl", nil, ["https://raw.githubusercontent.com/gamache/fuzzyurl/master/LICENSE.txt"]],
        ["jwt", nil, ["https://github.com/jwt/ruby-jwt/blob/master/LICENSE"]],
        ["win32-process", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-api", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-dir", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-ipc", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-event", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-eventlog", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-mmap", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-mutex", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["win32-service", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["windows-api", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["rdoc", "Ruby", ["https://raw.githubusercontent.com/rdoc/rdoc/master/LICENSE.rdoc"]],
        ["rest-client", "MIT", ["https://raw.githubusercontent.com/rest-client/rest-client/master/LICENSE"]],
        ["rspec-rerun", nil, ["https://raw.githubusercontent.com/dblock/rspec-rerun/master/LICENSE.md"]],
        ["amqp", "Ruby", ["https://raw.githubusercontent.com/ruby-amqp/amqp/master/README.md"]],
        ["fast_xs", "MIT", ["https://raw.githubusercontent.com/brianmario/fast_xs/master/LICENSE"]],
        ["word-salad", "MIT", ["https://raw.githubusercontent.com/alexvollmer/word_salad/master/README.txt"]],
        ["minitest", nil, ["https://raw.githubusercontent.com/seattlerb/minitest/master/README.rdoc"]],
        ["cucumber-wire", nil, ["https://raw.githubusercontent.com/cucumber/cucumber-ruby-wire/master/LICENSE"]],
        ["minitar", "Ruby", ["https://raw.githubusercontent.com/atoulme/minitar/master/README"]],
        ["enumerable-lazy", "MIT", ["https://raw.githubusercontent.com/yhara/enumerable-lazy/master/README.md"]],
        ["rack-accept", "MIT", ["https://raw.githubusercontent.com/mjackson/rack-accept/master/README.md"]],
        ["net-http-spy", "Public-Domain", ["https://raw.githubusercontent.com/martinbtt/net-http-spy/master/readme.markdown"]],
        ["http_parser.rb", nil, ["https://raw.githubusercontent.com/tmm1/http_parser.rb/master/LICENSE-MIT"]],
        ["websocket-extensions", nil, ["https://raw.githubusercontent.com/faye/websocket-extensions-ruby/master/LICENSE.md"]],
        ["websocket-driver", nil, ["https://raw.githubusercontent.com/faye/websocket-driver-ruby/master/LICENSE.md"]],
        ["dep_selector", nil, ["https://raw.githubusercontent.com/chef/dep-selector/master/LICENSE"]],
        ["overcommit", nil, ["https://raw.githubusercontent.com/brigade/overcommit/master/MIT-LICENSE"]],
        ["github_changelog_generator", nil, ["https://raw.githubusercontent.com/skywinder/github-changelog-generator/master/LICENSE"]],
        ["pbkdf2", "MIT", ["https://raw.githubusercontent.com/emerose/pbkdf2-ruby/master/LICENSE.TXT"]],
        ["rails-deprecated_sanitizer", nil, ["https://raw.githubusercontent.com/rails/rails-deprecated_sanitizer/master/LICENSE"]],
        ["rails-html-sanitizer", nil, ["https://raw.githubusercontent.com/rails/rails-html-sanitizer/master/MIT-LICENSE"]],
        ["compass", "MIT", ["https://raw.githubusercontent.com/Compass/compass/stable/LICENSE.markdown"]],
        ["railties", nil, ["https://raw.githubusercontent.com/rails/rails/master/railties/MIT-LICENSE"]],
        ["coffee-script-source", nil, ["https://raw.githubusercontent.com/jessedoyle/coffee-script-source/master/LICENSE"]],
        ["omniauth-chef", nil, ["https://raw.githubusercontent.com/chef/omniauth-chef/master/README.md"]],
        ["rails", nil, ["https://raw.githubusercontent.com/rails/rails/master/README.md"]],
        ["unicorn-rails", "MIT", ["https://raw.githubusercontent.com/samuelkadolph/unicorn-rails/master/LICENSE"]],
        ["hoe", "MIT", ["https://raw.githubusercontent.com/seattlerb/hoe/master/README.rdoc"]],
      ].each do |override_data|
        override_license "ruby_bundler", override_data[0] do |version|
          {}.tap do |d|
            d[:license] = override_data[1] if override_data[1]
            d[:license_files] = override_data[2] if override_data[2]
          end
        end
      end

      [
        ["apt", nil, ["https://raw.githubusercontent.com/chef-cookbooks/apt/master/LICENSE"]],
        ["chef-ha-drbd", nil, ["https://raw.githubusercontent.com/chef/chef-server/master/LICENSE"]],
        ["private-chef", nil, ["https://raw.githubusercontent.com/chef/chef-server/master/LICENSE"]],
        ["chef-sugar", nil, ["https://raw.githubusercontent.com/sethvargo/chef-sugar/master/LICENSE"]],
        ["openssl", nil, ["https://raw.githubusercontent.com/chef-cookbooks/openssl/master/LICENSE"]],
        ["runit", nil, ["https://raw.githubusercontent.com/chef-cookbooks/runit/master/LICENSE"]],
        ["yum", nil, ["https://raw.githubusercontent.com/chef-cookbooks/yum/master/LICENSE"]],
      ].each do |override_data|
        override_license "chef_berkshelf", override_data[0] do |version|
          {}.tap do |d|
            d[:license] = override_data[1] if override_data[1]
            d[:license_files] = override_data[2] if override_data[2]
          end
        end
      end

      # Most of the overrides for perl_cpan are pointing to the README files
      # inside the modules we download to inspect for licensing information.
      [
        ["Scalar-List-Utils", nil, ["README"]],
        ["perl", nil, ["README"]],
        ["IO", nil, ["README"]],
        ["ExtUtils-MakeMaker", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["PathTools", "Perl-5", ["lib/File/Spec.pm"]],
        ["Exporter", nil, ["README"]],
        ["Carp", nil, ["README"]],
        ["lib", nil, ["Artistic"]],
        ["Pod-Escapes", nil, ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["Pod-Usage", nil, ["README"]],
        ["base", "Perl-5", ["http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt"]],
        ["Encode", nil, ["AUTHORS"]],
        ["Moo", nil, ["README"]],
        ["Role-Tiny", nil, ["README"]],
        ["Try-Tiny", nil, ["LICENCE"]],
        ["Module-Metadata", nil, ["LICENCE"]],
        ["constant", nil, ["README"]],
        ["Module-Runtime", nil, ["README"]],
        ["ExtUtils-Install", nil, ["README"]],
        ["File-Path", nil, ["README"]],
        ["Getopt-Long", "Perl-5", ["README"]],
        ["ExtUtils-ParseXS", "Perl-5", ["README"]],
        ["version", nil, ["README"]],
        ["Data-Dumper", "Perl-5", ["Dumper.pm"]],
        ["Test-Harness", nil, ["README"]],
        ["Text-ParseWords", nil, ["README"]],
        ["Devel-GlobalDestruction", nil, ["README"]],
        ["XSLoader", nil, ["README"]],
        ["IPC-Cmd", nil, ["README"]],
        ["Pod-Parser", "Perl-5", ["README"]],
        ["Config-GitLike", nil, ["lib/Config/GitLike.pm"]],
        ["Test-Exception", nil, ["lib/Test/Exception.pm"]],
        ["MooX-Types-MooseLike", nil, ["README"]],
        ["String-ShellQuote", "Perl-5", ["README"]],
        ["Time-HiRes", nil, ["README"]],
        ["Test", "Perl-5", ["README"]],
        ["parent", nil, ["lib/parent.pm"]],
        ["MIME-Base64", nil, ["README"]],
        ["Sub-Identify", nil, ["lib/Sub/Identify.pm"]],
        ["namespace-autoclean", nil, ["README"]],
        ["B-Hooks-EndOfScope", nil, ["README"]],
        ["namespace-clean", nil, ["lib/namespace/clean.pm"]],
        ["Test-Deep", nil, ["lib/Test/Deep.pm"]],
        ["IO-Pager", "Perl-5", ["README"]],
        ["libintl-perl", "GPL-3.0", ["COPYING"]],
        ["Storable", "Perl-5", ["README"]],
        ["Test-Warnings", "Artistic-1.0", ["LICENCE"]],
        ["Test-Dir", nil, ["README"]],
        ["Digest-SHA", nil, ["README"]],
        ["Test-File-Contents", nil, ["README"]],
        ["Digest-MD5", nil, ["README"]],
        ["Algorithm-Diff", "Perl-5", ["lib/Algorithm/Diff.pm"]],
        ["Encode-Locale", nil, ["README"]],
        ["Hash-Merge", nil, ["README"]],
        ["Clone", nil, ["README"]],
        ["URI-db", nil, ["README"]],
        ["URI-Nested", nil, ["README.md"]],
        ["Test-utf8", nil, ["README"]],

      ].each do |override_data|
        override_license "perl_cpan", override_data[0] do |version|
          {}.tap do |d|
            d[:license] = override_data[1] if override_data[1]
            d[:license_files] = override_data[2] if override_data[2]
          end
        end
      end

      [
        ["sync", "MIT", ["https://raw.githubusercontent.com/rustyio/sync/11df81d196eaab2d84caa3fbe8def5d476ef79d8/src/sync.erl"]],
        ["rebar_vsn_plugin", "Apache-2.0", ["https://raw.githubusercontent.com/erlware/rebar_vsn_plugin/master/src/rebar_vsn_plugin.erl"]],
        ["edown", "Erlang-Public", ["https://raw.githubusercontent.com/seth/edown/master/NOTICE"]],
        ["bcrypt", "Multiple", ["https://github.com/chef/erlang-bcrypt/blob/master/LICENSE"]],
        ["amqp_client", "MPL-2.0", ["https://raw.githubusercontent.com/seth/amqp_client/7622ad8093a41b7288a1aa44dd16d3e92ce8f833/src/amqp_connection.erl"]],
        ["erlsom", "LGPL-3.0", ["https://raw.githubusercontent.com/willemdj/erlsom/c5ca9fca1257f563d78b048e35ac60832ec80584/COPYING", "https://raw.githubusercontent.com/willemdj/erlsom/c5ca9fca1257f563d78b048e35ac60832ec80584/COPYING.LESSER"]],
        ["gen_server2", "Public-Domain", ["https://raw.githubusercontent.com/mdaguete/gen_server2/master/README.md"]],
        ["opscoderl_folsom", "Apache-2.0", ["https://raw.githubusercontent.com/chef/opscoderl_folsom/master/README.md"]],
        ["quickrand", "BSD-2-Clause", ["https://raw.githubusercontent.com/okeuday/quickrand/master/README.markdown"]],
        ["rabbit_common", "MPL-2.0", ["https://raw.githubusercontent.com/muxspace/rabbit_common/master/include/rabbit_msg_store.hrl"]],
        ["uuid", "BSD-2-Clause", ["https://raw.githubusercontent.com/okeuday/uuid/master/README.markdown"]],
      ].each do |override_data|
        override_license "erlang_rebar", override_data[0] do |version|
          {}.tap do |d|
            d[:license] = override_data[1] if override_data[1]
            d[:license_files] = override_data[2] if override_data[2]
          end
        end
      end
    end

  end
end
