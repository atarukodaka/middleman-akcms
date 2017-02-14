module Middleman::Akcms
  class Extension < Middleman::Extension
    ## default options
    option :layout, "layout", "article specified layout"  # :_auto_layout

    ## directory summary settings
    option :directory_summary_template, nil #'templates/directory_summary_template.html'
    
    ## archive settings
    option :archive_template, nil       # 'templates/archive_template.html'
    option :archive_link, 'archives/%<year>04d-%<month>02d.html'

    ## pagination settings
    option :pagination, true
    option :pagination_per_page, 5
    option :pagination_page_link, "page-%{page_number}"

    ## series settings
    option :series_title_template, "%{name} #%{number}: %{article_title}" 

    ## summarizer
    require 'middleman-akcms/summarize'
    option :summary_length, 250, 'length of charactor to summrize'
    option :summarizer, Middleman::Akcms::OgaSummarizer

    ## helpers
    helpers do
      def resource_for(path)
        sitemap.find_resource_by_path(path)
      end

      def top_page
        sitemap.find_resource_by_path("/" + config[:index_file])
      end
    end
    
    def initialize(app, options_hash = {}, &block)
      super

      app.config[:akcms] = {
        layout: options.layout,
        directory_summary_template: options.directory_summary_template,
        summary_length: options.summary_length,
        pagination: {
          per_page: options.pagination_per_page,
          page_link: options.pagination_page_link
        },
        archive: {
          template: options.archive_template,
          link: options.archive_link
        },
        series: {
          title_template: options.series_title_template
        },
        summarizer: options.summarizer.new
      }
      
      ## activate relevant extensions
      app.extensions.activate(:akcms_article)
      if (t = options.directory_summary_template)
        app.extensions.activate(:akcms_directory_summary)
        app.ignore t
      end
      if (t = options.archive_template)
        app.extensions.activate(:akcms_archive)
        app.ignore t
      end
      app.extensions.activate(:akcms_pagination) if options.pagination
      app.extensions.activate(:akcms_series)
    end
  end  ## class
end
