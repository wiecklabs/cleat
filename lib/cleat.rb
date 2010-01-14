require 'rubygems'

require "harbor"
require "harbor/contrib/session/data_mapper"
require "harbor/contrib/stats"

require "port_authority"

$:.unshift(Pathname(__FILE__).dirname.expand_path)

Harbor::View::path.unshift(Pathname(__FILE__).dirname + "cleat" + "views")
Harbor::View::layouts.default("layouts/application")

class Cleat < Harbor::Application

  module Admin
    autoload :Links, "cleat/controllers/admin/links"
  end

  def self.routes(services)
    Harbor::Router.new do

      using services, Admin::Links do
        get("/admin/links") { |links| links.index }
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
end

require "cleat/models/link"