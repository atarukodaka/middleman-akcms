module Middleman::Akcms::Archive
  module InstanceMethodsToStore
    include Contracts
    
    Contract nil => HashOf[Date => ResourceList]
    def archives
      @app.extensions[:akcms_archive].archives
    end
    Contract nil => HashOf[Date => Middleman::Sitemap::Resource]
    def archive_resources
      @app.extensions[:akcms_archive].archive_resources
    end
  end
end

module Middleman::Akcms::Archive
  class Extension < Middleman::Extension
    include Contracts
    
    attr_reader :archives, :archive_resources
    
    def after_configuration
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end

    Contract String, Hash => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(link, metadata = {})
      template = @app.config.akcms[:archive][:template]
      Middleman::Sitemap::ProxyResource.new(@app.sitemap, link, template).tap do |p|
        p.add_metadata(metadata)
      end
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      @archives = {}
      @archive_resources = {}
 
      group_by_month(resources.select {|r| r.is_article?}).each {|month, articles|
        @archive_resources[month] = create_proxy_resource(link(month), locals: {date: month, articles: articles})
        @archives[month] = articles
      }
      return resources + @archive_resources.values.sort_by {|res| res.locals[:date]}.reverse
    end
    
    ################
    private
    Contract Date => String
    def link(month)
      @app.config.akcms[:archive][:link] % {year: month.year, month: month.month}
    end
    Contract ResourceList => Hash
    def group_by_month(resources)
      resources.group_by {|a| Date.new(a.date.year, a.date.month, 1)}
    end
  end # class
end
