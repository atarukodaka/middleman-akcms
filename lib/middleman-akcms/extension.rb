#require 'middleman-akcms/controller'
#require 'middleman-akcms/helpers'
require 'middleman-akcms/summarize'

module Middleman::Akcms
  class Extension < Middleman::Extension
    attr_reader :controller
    
    ## helpers for use within templates and layouts.
    #self.defined_helpers = [ Middleman::Akcms::Helpers ]
    
    ## default options
    option :layout, "article"

    ## directory summary settings
    option :directory_summary_template, 'templates/directory_summary_template.html'
    
    ## archive settings
    option :archive_template, nil       # 'templates/archive_template.html'
    option :archive_link, 'archives/%<year>04d-%<month>02d.html'

    ## tag settings
    option :tag_template, nil           # 'templates/tag_template.html'
    option :tag_link, 'tags/%{tag}.html'

    ## pagination settings
    option :pagination, true
    option :pagination_per_page, 5
    option :pagination_page_link, "page-%{page_number}"

    ## series settings
    option :series_title_template, "%{name} #%{number}: %{article_title}" 

    ## label
    option :top_page_label, "Home"

    ## summarizer
    option :summary_length, 250         # length of charactor to summrize
    option :summarizer, Middleman::Akcms::OgaSummarizer

    attr_reader :summarizer

    def initialize(app, options_hash = {}, &block)
      super
      app.config.akcms = {}
      app.extensions.activate(:akcms_article)
      app.extensions.activate(:akcms_directory_summary)
    end
    
    def after_configuration
      #app.extensions.activate(Middleman::Akcms::ArticleExtension)
      app.config[:akcms] = {
        layout: options.layout,
        directory_summary_template: options.directory_summary_template,
        summary_length: options.summary_length
      }

      @summarizer = options.summarizer.new
    end
    def manipulate_resource_list(resources)
      resources
    end
  end  ## class
end
