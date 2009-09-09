require "rubygems"
require "pathname"
require "test/unit"
require Pathname(__FILE__).dirname.parent + "lib/cleat"

DataMapper.setup :default, "sqlite3::memory:"
DataMapper.auto_migrate!

Cleat::whitelist! ""