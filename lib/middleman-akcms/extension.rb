require 'hashie'

require 'middleman-akcms/controller'
require 'middleman-akcms/helpers'
require 'middleman-akcms/contracts'

################
# Array Helper
=begin
module Middleman::Akcms
  module FinderArrayHelper
    def find_by(type, value)
      find {|res| res.send(type) == value}
    end
    def select_by(type, value)
      select {|res| res.send(type) == value}
    end
  end
end
=end
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
    option :pagination_per_page, 5
    option :pagination_page_link, "page-%{page_number}"

    ## series settings
    option :series_title_template, "%{name} #%{number}: %{title}" 
    
    ## Hooks
    def after_configuration
      #Array.include FinderArrayHelper
      
      @controller = Middleman::Akcms::Controller.new(self)
      @controller.register_manipulators
    end
  end  ## class
end
