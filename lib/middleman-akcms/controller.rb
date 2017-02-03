module Middleman::Akcms
  class Controller
    include Contracts

    attr_reader :app, :extension, :options
    attr_reader :manipulators

    def initialize(extension)
      @extension = extension
      @app = extension.app
      @options = extension.options

      @manipulators = {}
    end

    ## accessors to contents in each manipulator
    Contract Array
    def articles
      @manipulators[:article].articles
    end

    Contract Hash
    def categories
      @manipulators[:category].try(:categories) || {}
    end

    Contract Hash
    def archives
      @manipulators[:archive].try(:archives) || {}
    end
    Contract Hash
    def tags
      @manipulators[:tag].try(:tags) || {}
    end

    ## register manipulators
    def register_manipulators
      require 'middleman-akcms/article'
      
      require 'middleman-akcms/directory_summary'
      require 'middleman-akcms/archive'
#      require 'middleman-akcms/category'
      require 'middleman-akcms/tag'
      require 'middleman-akcms/paginator'
      require 'middleman-akcms/series'
      
      ## [enable?, id, class]
      manips = [
                [true, :article, ArticleManipulator], 
                [options.directory_summary_template, :directry_summary, DirectorySummaryManipulator],
                [options.archive_template, :archive, ArchiveManipulator],
                [options.tag_template, :tag, TagManipulator],
                [true, :paginator, PaginatorManipulator],
                [true, :series, SeriesManipulator],
               ]
      
      manips.each {|ar|
        enabled, m_id, klass = ar

        if enabled
          app.sitemap.register_resource_list_manipulator(m_id, @manipulators[m_id] = klass.new(self))
        end
        ## ignore template
        app.ignore options.archive_template if options.archive_template
        app.ignore options.directory_summary_template if options.directory_summary_template
        app.ignore options.tag_template if options.tag_template
      }
    end
  end  ## class
end
