require 'rubygems'
require "bundler/setup"

require 'logger'
require 'yaml'
require 'ruby2ruby'
require 'ruby_parser'
require 'sorcerer'

require 'pry_tester'

require 'core/string'

require 'cauldron/pot'
require 'cauldron/terminal'
require 'cauldron/relationship'
require 'cauldron/if_relationship'
require 'cauldron/operator/numeric_operator'
require 'cauldron/operator/concat_operator'
require 'cauldron/operator/array_reverse_operator'
require 'cauldron/operator/hash_key_value_operator'
require 'cauldron/operator/string_asterisk_operator'
require 'cauldron/operator/array_collect'
require 'cauldron/operator/to_s_operator'

require 'cauldron/solution/one'
require 'cauldron/solution/composite'