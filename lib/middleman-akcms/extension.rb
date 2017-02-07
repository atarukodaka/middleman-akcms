require 'middleman-akcms/controller'
require 'middleman-akcms/helpers'
require 'middleman-akcms/contracts'

################
module Middleman::Akcms
  class Extension < Middleman::Extension
    attr_reader :controller
    
    ## helpers for use within templates and layouts.
    self.defined_helpers = [ Middleman::Akcms::Helpers ]
    
    ## default options
    option :layout, "article"
    option :summary_length, 250         # length of charactor to summrize

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
    option :series_title_template, "%{name} #%{number}: %{title}" 

    ## label
    option :top_page_default_label, "Home"

    ## summarizer
    option :summarizer, OgaSummarizer
    
    ## Hooks
    def after_configuration
      @controller = Middleman::Akcms::Controller.new(self)
      @controller.register_manipulators
    end
  end  ## class
end
