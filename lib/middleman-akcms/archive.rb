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
      def disable?(controller)
        controller.extension.options.archive_template.nil?
      end
    end
    Middleman::Akcms::Controller.register(:archive, self)
    ################
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    attr_reader :archives, :archive_resources
    
    def initialize(controller)
      controller.extend ControllerInstanceMethods
      super(controller, controller.options.archive_template)
    end
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      @archives = {}
      @archive_resources = {}
 
      group_by_month(controller.articles).each {|month, articles|
        @archive_resources[month] = create_proxy_resource(link(month), date: month, articles: articles)
        @archives[month] = articles
      }
      return resources + @archive_resources.values.sort_by {|res| res.locals[:date]}.reverse
    end
    
    ################
    private
    Contract Date => String
    def link(month)
      @controller.options.archive_link % {year: month.year, month: month.month}
    end
    Contract ArrayOf[C::Resource] => Hash
    def group_by_month(resources)
      resources.group_by {|a| Date.new(a.date.year, a.date.month, 1)}
    end
  end # class
end
