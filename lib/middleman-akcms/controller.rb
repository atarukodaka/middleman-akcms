require 'contracts'
require 'middleman-akcms/summary'

module Middleman::Akcms
  class Controller
    @registered = {}
    class << self
      attr_reader :registered

      def register(id, klass)
        @registered[id] = klass
      end
    end

    include Contracts

#    attr_reader :app, :extension, :options, :manipulators
    attr_reader :app, :options, :manipulators

    def initialize(extension)
      @extension = extension
      @app = extension.app
      @options = extension.options
      @manipulators = {}

      @summarize = Summarize.new(options.summarizer || OgaSummaizer)
    end
    
    Contract Middleman::Sitemap::Resource, Integer => String
    def summary(resource, length=nil)
      length ||= options.summary_length || 250
      @summarize.summary(resource, length)
    end
                
    Contract Array
    def articles
      @manipulators[:article].articles
    end
    
    ## register manipulators
    Contract nil => Any
    def register_manipulators
      require 'middleman-akcms/article'
      require 'middleman-akcms/archive'
      require 'middleman-akcms/tag'
      require 'middleman-akcms/directory_summary'
      require 'middleman-akcms/paginator'
      require 'middleman-akcms/series'

      self.class.registered.each {|id, klass|
        unless klass.respond_to?(:disable?) && klass.disable?(self)
          app.sitemap.register_resource_list_manipulator(id, @manipulators[id] = klass.new(self))
        end
      }
    end
  end  ## class
end
