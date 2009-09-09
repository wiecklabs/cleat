#!/usr/bin/env ruby

# gem "harbor", ">= 0.12"
# require "harbor"

require "lib/cleat"
require "harbor/logging"

services = Harbor::Container.new
services.register("mailer", Harbor::Mailer)
services.register("mail_server", Harbor::MailServers::Sendmail)

Harbor::Mailer.host = "localhost:3000"

DataMapper.setup :default, "sqlite3://#{Pathname(__FILE__).dirname.expand_path + "urls.db"}"

Cleat::whitelist! "" # Match any domain, DO NOT use this on a production application!

if $0 == __FILE__
  require "harbor/console"
  Harbor::Console.start
else
  run Cleat.new(services)
end