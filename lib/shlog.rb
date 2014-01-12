# Require dev shit
if ENV["DEV_MODE"] == "debug"
  require "ap" rescue nil
end

# Require Standard Library shit
require "psych"
require "erb"

# Require gems shit
require "gli"
require "rainbow/ext/string"
require "lumberjack"

# Require personal shit
require_relative "./shlog/version"
require_relative "./shlog/basic_cli"
require_relative "./shlog/cli"
