require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class ArchiveManipulator < Manipulator
    module ControllerInstanceMethods
      def archives
        @manipulators[:archive].archives
      end
      def archive_resources
        @manipulators[:archive].archive_resources
      end
    end

    class << self
      def enable?(controller)
        controller.extension.options.archive_template
      end
    end

    include Contracts
    
    attr_reader :archives, :archive_resources
    
    def initialize(controller)
      @template = controller.options.archive_template
      controller.extend ControllerInstanceMethods
      super(controller)
    end
    
    
    Contract Array => Array    
    def manipulate_resource_list(resources)
      @archives = {}
      @archive_resources = {}

      group_by_date_ym(@controller.articles).each {|date_ym, articles|
        @archive_resources[date_ym] = create_proxy_resource(link(date_ym),
                                                          date: date_ym,
                                                          articles: articles)
        @archives[date_ym] = articles
      }
      return resources + @archive_resources.values.sort_by {|res| res.locals[:date]}.reverse
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
    Middleman::Akcms::Controller.register(:archive, self)
  end # class
end
