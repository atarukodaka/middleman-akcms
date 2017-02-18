require 'active_support/time_with_zone'
require 'active_support/core_ext/time/calculations'
require 'middleman-akcms/util'

module Middleman::Akcms::Archive
  include Contracts
  TypeSymbol = Or[:year, :month, :day]
  
  module InstanceMethodsToStore
    include Contracts

    # e.g. archives[:month].each do |date, res|...
    Contract HashOf[TypeSymbol => HashOf[ActiveSupport::TimeWithZone => Middleman::Sitemap::ProxyResource]]
    def archives
      @app.extensions[:akcms_archive].archives
    end
  end
end

module Middleman::Akcms::Archive
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts
    
    attr_reader :archives
    
    def after_configuration
      ## add 'archives' methods into sitemap
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      @archives = {year: {}, month: {}, day: {}}
      new_resources = []
      articles = select_articles(resources)

      [:year, :month, :day].each do |type|
        template = @app.config.akcms[:archive][type][:template]
        next if template.blank?

        group_by_type(type, articles).each do |date, d_articles|
          md = {locals: {date: date, articles: d_articles, archive_type: type}}
          
          create_proxy_resource(@app.sitemap, link_path(type, date), template, md).tap do |p|
            @archives[type][date] = p
            new_resources << p
          end
        end
      end
      return resources + new_resources
    end
    
    private
    Contract TypeSymbol, ActiveSupport::TimeWithZone => String
    def link_path(type, date)
      @app.config.akcms[:archive][type][:link] % {year: date.year, month: date.month, day: date.day}
    end

    Contract TypeSymbol, ResourceList => HashOf[ActiveSupport::TimeWithZone => ResourceList]
    def group_by_type(type, resources)
      case type
      when :year
        resources.group_by {|a| a.date.beginning_of_year }
      when :month
        resources.group_by {|a| a.date.beginning_of_month }
      when :day
        resources.group_by {|a| a.date.beginning_of_day }
      end
    end
  end # class
end
