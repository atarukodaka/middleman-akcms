require 'middleman-akcms/manipulator'

=begin
class Date
  def beginning_of_month
    Date.new(year, month, 1)
  end
end
class Date
  def to_month
    Middleman::Akcms::Month(year, month)
  end
end
=end
module Middleman::Akcms
=begin
  class Month
    attr_reader :date
    
    def initialize(year, month)
      @date = Date.new(year, month, 1)
    end
    def to_date
      @date
    end
    def to_hash
      {year: @date.year, month: @date.month}
    end
    def method_missing(name, *args)
      @date.send name, *args
    end
  end
=end

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
      controller.app.ignore @template = controller.options.archive_template
      controller.extend ControllerInstanceMethods
      super(controller)
    end
    
    
    Contract Array => Array    
    def manipulate_resource_list(resources)
      @archives = {}
      @archive_resources = {}

      group_by_month(controller.articles).each {|month, articles|
        @archive_resources[month] = create_proxy_resource(link(month),
                                                          date: month,
                                                          articles: articles)
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
    Contract Array => Hash

    def group_by_month(resources)
      #resources.group_by {|res| Month.new(res.date)}
      resources.group_by {|a| Date.new(a.date.year, a.date.month, 1)}
    end

    Middleman::Akcms::Controller.register(:archive, self)
  end # class
end
