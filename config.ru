#!/usr/bin/env ruby

ENV["ENVIRONMENT"] ||= "development"
require "vendor/environment"
require "lib/cleat"

services = Harbor::Container.new
services.register("mailer", Harbor::Mailer)
services.register("mail_server", Harbor::MailServers::Sendmail)

DataMapper.setup :default, "postgres://localhost/cleat_development"

Harbor::Session.configure { |session| session[:store] = Harbor::Contrib::Session::DataMapper }
Harbor::Contrib::Stats.orm = "data_mapper"

Harbor::View.plugins("admin/links") << '<a href="/admin/links">Links</a>'

UI::public_path = Cleat::public_path

if $0 == __FILE__
  require "harbor/console"
  Harbor::Console.start
else $0['thin']
  run Harbor::Cascade.new(
    ENV['ENVIRONMENT'],
    services,
    Cleat, PortAuthority
  )
end
