module Middleman::Akcms
  class Extension < Middleman::Extension
    ## default options
    option :layout, "layout", "article specified layout"  # :_auto_layout

    ## directory summary settings
    option :directory_summary_template, nil #'templates/directory_summary_template.html'
    
    ## archive settings
    option :archive_year_template, nil       # 'templates/archive_template.html'
    option :archive_year_link, 'archives/%<year>04d.html'
    option :archive_month_template, nil       # 'templates/archive_template.html'
    option :archive_month_link, 'archives/%<year>04d-%<month>02d.html'
    option :archive_day_template, nil       # 'templates/archive_template.html'
    option :archive_day_link, 'archives/%<year>04d-%<month>02d-%<day>02d.html'

    ## tag settings
    option :tag_template, nil
    option :tag_link, "tags/%{tag}.html"
    
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
=begin
      def top_page
        sitemap.find_resource_by_path("/" + config[:index_file])
      end
=end
    end

    def initialize(app, options_hash = {}, &block)
      super
      set_config
      activate_relevant_extensions
    end

    def set_config
      app.config[:akcms] = {
        layout: options.layout,
        summarize: {
          summary_length: options.summary_length,
          summarizer: options.summarizer.new
        },
        directory_summary_template: options.directory_summary_template,
        pagination: {
          per_page: options.pagination_per_page,
          page_link: options.pagination_page_link
        },
        archive: {
          year: {
            template: options.archive_year_template,
            link: options.archive_year_link
          },
          month: {
            template: options.archive_month_template,
            link: options.archive_month_link
          },
          day: {
            template: options.archive_day_template,
            link: options.archive_day_link
          }
        },
        tag: {
          template: options.tag_template,
          link: options.tag_link
        },
        series: {
          title_template: options.series_title_template
        }
      }
    end
    
    def activate_relevant_extensions
      app.extensions.activate(:akcms_article)
      if (t = options.directory_summary_template)
        app.extensions.activate(:akcms_directory_summary)
        app.ignore t
      end
      archive_templates = [options.archive_year_template, options.archive_month_template, options.archive_day_template]
      if archive_templates.any?
        app.extensions.activate(:akcms_archive)
        archive_templates.each do |template|
          app.ignore template if template
        end
      end
      app.extensions.activate(:akcms_tag) if options.tag_template
      app.extensions.activate(:akcms_pagination) if options.pagination
      app.extensions.activate(:akcms_series)
    end      
  end  ## class
end
