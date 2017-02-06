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

    attr_reader :app, :extension, :options, :manipulators

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

    ## register manipulators
    def register_manipulators
      
      require 'middleman-akcms/article'
      require 'middleman-akcms/directory_summary'
      require 'middleman-akcms/archive'
      require 'middleman-akcms/tag'
      require 'middleman-akcms/paginator'
      require 'middleman-akcms/series'
      
      self.class.registered.each {|id, klass|
        if klass.enable?(self)
          app.sitemap.register_resource_list_manipulator(id, @manipulators[id] = klass.new(self))
        end
      }
    end
  end  ## class
end
