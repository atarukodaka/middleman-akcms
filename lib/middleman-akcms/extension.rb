require 'active_support/core_ext/time/zones'

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
    # option :series_title_template, "%{name} [%{number}]: %{article_title}" 

    ## summarizer
    require 'middleman-akcms/summarize'
    option :summary_length, 250, 'length of charactor to summrize'
    option :summarizer, Middleman::Akcms::OgaSummarizer
    
    def initialize(app, options_hash = {}, &block)
      super
      app.config.akcms = options_to_config()
      activate_relevant_extensions()
    end

    def after_configuration
      ## activesupport timezone
      Time.zone = app.config[:time_zone] if app.config[:time_zone]
      time_zone = Time.zone || 'UTC'
      zone_default = Time.find_zone!(time_zone)
      unless zone_default
        raise 'Value assigned to time_zone not recognized.'
      end
      Time.zone_default = zone_default
    end

    
    # rubocop:disable Metrics/MethodLength
    def options_to_config
      {
        layout: options.layout,
        summarize: {
          summary_length: options.summary_length,
          summarizer: options.summarizer.new,
        },
        directory_summary_template: options.directory_summary_template,
        pagination: {
          per_page: options.pagination_per_page,
          page_link: options.pagination_page_link,
        },
        archive: {
          year: {
            template: options.archive_year_template,
            link: options.archive_year_link,
          },
          month: {
            template: options.archive_month_template,
            link: options.archive_month_link,
          },
          day: {
            template: options.archive_day_template,
            link: options.archive_day_link,
          },
        },
        tag: {
          template: options.tag_template,
          link: options.tag_link,
        },
=begin
        series: {
          title_template: options.series_title_template,
        },
=end
      }
    end
    # rubocop:enable Metrics/MethodLength
    
    def activate_relevant_extensions
      [:article, :directory_summary, :archive, :tag, :pagination].each do |ext|
        app.extensions.activate(("akcms_" + ext.to_s).to_sym)
      end

      [:directory_summary, :archive_year, :archive_month, :archve_day, :tag].each do |t|
        if template = options["#{t.to_s}_template".to_sym]        
          app.ignore(template)
        end
      end
    end      
  end  ## class
end
