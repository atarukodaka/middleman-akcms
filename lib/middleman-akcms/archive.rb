require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class ArchiveManipulator < Manipulator
    include Contracts
    
    attr_reader :archives

    def initialize(controller)
      super(controller)
      @template = controller.options.archive_template
    end

    Contract Array => Array    
    def manipulate_resource_list(resources)
      @archives = {}

      group_by_date_ym(@controller.articles).each {|date_ym, articles|
        @archives[date_ym] = create_proxy_resource(link(date_ym),
                                                   date: date_ym, articles: articles)
      }
      return resources + @archives.values.sort_by {|res| res.locals[:date]}.reverse
    end
    
    ################
    private
    Contract Date => String
    def link(date)
      @controller.options.archive_link % {year: date.year, month: date.month}      
    end
    Contract Array => Hash
    def group_by_date_ym(resources)
      resources.group_by {|a| Date.new(a.date.year, a.date.month, 1)}
    end
  end # class
end
