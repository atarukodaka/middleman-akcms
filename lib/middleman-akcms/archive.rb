require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class ArchiveManipulator < Manipulator
    include Contracts
    
    attr_reader :archives

    def initialize(controller)
      super(controller)

      @template = controller.options.archive_template
    end

    Contract Date, Array => Middleman::Sitemap::ProxyResource
    def __create_proxy_resource(sym, date, articles = [])
      Middleman::Sitemap::ProxyResource.new(@sitemap, link(date), @template).tap do |p|
        p.add_metadata(locals: {date: date, articles: articles})
      end
    end

    Contract Array => Array    
    def manipulate_resource_list(resources)
      @archives = {}

      @controller.articles.group_by {|a| 
        Date.new(a.date.year, a.date.month, 1)}.each {|date_ym, articles|
        @archives[date_ym] = create_proxy_resource(:date, date_ym, articles)
      }
      return resources + @archives.values.sort_by {|res| res.locals[:date]}.reverse
    end
    
    ################################################################
    private
    Contract Date => String
    def link(date)
      @controller.options.archive_link % {year: date.year, month: date.month}      
    end
  end # class
end
