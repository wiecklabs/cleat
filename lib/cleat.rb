require 'rubygems'

require "harbor"
require "harbor/contrib/session/data_mapper"
require "harbor/contrib/stats"

require "port_authority"

$:.unshift(Pathname(__FILE__).dirname.expand_path)

Harbor::View::path.unshift(Pathname(__FILE__).dirname + "cleat" + "views")
Harbor::View::layouts.map("cleat/not_found", "layouts/exception")
Harbor::View::layouts.default("layouts/application")

class Cleat < Harbor::Application

  autoload :Controller, "cleat/controllers/controller"

  module Admin
    autoload :Links, "cleat/controllers/admin/links"
  end

  def self.routes(services)
    Harbor::Router.new do

      using services, Admin::Links do
        get("/admin/links") do |links, params|
          links.index(
            params.fetch("page", 1),
            params.fetch("page_size", 100),
            params.fetch("query", nil)
          )
        end

        get("/admin/links/expired") do |links, params|
          links.expired(
            params.fetch("page", 1),
            params.fetch("page_size", 100),
            params.fetch("query", nil)
          )
        end

        get("/admin/links/new") { |links| links.new }
        get("/admin/links/:id") { |links, params| links.edit(params["id"]) }

        post("/admin/links") do |links, params|
          link_params = params["link"]
          link_params.delete("start_date") if link_params["start_date"].blank?
          link_params.delete("end_date") if link_params["end_date"].blank?

          links.create(link_params)
        end

        put("/admin/links/:id") do |links, params|
          link_params = params["link"]
          link_params.delete("start_date") if link_params["start_date"].blank?
          link_params.delete("end_date") if link_params["end_date"].blank?

          links.update(params["id"], link_params)
        end

        post("/admin/links/:id/statistics") do |links, params|
          links.statistics(params["id"], params["start_date"], params["end_date"])
        end

        get("/admin/links/:id/statistics") do |links, params|
          links.export_statistics(params["id"], params["start_date"], params["end_date"])
        end
      end

      using services, Controller do
        get(/^\/#{Regexp.escape(Cleat.prefix)}(.*)$/) do |controller, request|
          if request.path_info =~ /^\/#{Regexp.escape(Cleat.prefix)}(.*)$/
            key = $1
            if key[-1] == ?!
              controller.show(key[0...-1])
            else
              controller.redirect(key)
            end
          end
        end
      end

    end
  end

  @@public_path = Pathname(__FILE__).dirname.parent.expand_path + "public"
  def self.public_path=(value)
    @@public_path = value
  end

  def self.public_path
    @@public_path
  end

  @@private_path = Pathname(__FILE__).dirname.parent.expand_path + "private"
  def self.private_path=(value)
    @@private_path = value
  end

  def self.private_path
    @@private_path
  end

  @@tmp_path = Pathname(__FILE__).dirname.parent.expand_path + "tmp"
  def self.tmp_path=(value)
    @@tmp_path = value
  end

  def self.tmp_path
    @@tmp_path
  end

  @@base_url = nil
  def self.base_url
    unless @@base_url
      @@base_url = Socket::gethostbyname(Socket::gethostname)[0] rescue 'localhost'
      warn "!! Cleat::base_url not set, defaulting to #{@@base_url} !!"
    end

    @@base_url
  end

  def self.base_url=(base_url)
    @@base_url = base_url
  end

  @@prefix = "~"
  def self.prefix
    @@prefix
  end

  def self.prefix=(prefix)
    @@prefix = prefix
  end
  
  def self.permissions
    {
      "Links" => %w(list create update statistics)
    }
  end

  PermissionSet::permissions.merge!(permissions)
end

require "cleat/helpers/cleat"
require "cleat/models/link"
require "cleat/models/link/search"
require "cleat/models/statistics/link_session_click"
require "cleat/models/statistics/link_user_click"
require "cleat/ui/link"