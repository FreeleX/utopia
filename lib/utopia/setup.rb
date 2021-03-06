# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Utopia
	# Used for setting up a Utopia web application, typically via `config/environment.rb`
	class Bootstrap
		def initialize(config_root, external_encoding: Encoding::UTF_8)
			@config_root = config_root
			
			@external_encoding = external_encoding
		end
		
		def setup
			setup_encoding
			
			setup_environment
			
			setup_load_path
			
			require_relative '../utopia'
		end
		
		def environment_path
			File.expand_path('environment.yaml', @config_root)
		end
		
		# If you don't specify these, it's possible to have issues when encodings mismatch on the server.
		def setup_encoding
			# TODO: Deprecate and remove this setup - it should be the responsibility of the server to set this correctly.
			if @external_encoding and Encoding.default_external != @external_encoding
				warn "Updating Encoding.default_external from #{Encoding.default_external} to #{@external_encoding}" if $VERBOSE
				Encoding.default_external = @external_encoding
			end
		end
		
		def setup_environment
			if File.exist? environment_path
				require 'yaml'
				
				# Load the YAML environment file:
				environment = YAML.load_file(environment_path)
				
				# We update ENV but only when it's not already set to something:
				ENV.update(environment) do |name, old_value, new_value|
					old_value || new_value
				end
			end
		end
		
		def setup_load_path
			# Allow loading library code from lib directory:
			$LOAD_PATH << File.expand_path('../lib', @config_root)
		end
	end
	
	# The main entry point for `config/environment.rb` for setting up the site.
	def self.setup(config_root = nil, **options)
		# We extract the directory of the caller to get the path to $root/config
		if config_root.nil?
			config_root = File.dirname(caller[0])
		end
		
		Bootstrap.new(config_root, **options).tap(&:setup)
	end
end
