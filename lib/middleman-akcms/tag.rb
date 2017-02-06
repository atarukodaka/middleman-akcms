require 'middleman-akcms/manipulator'

module Middleman::Akcms
  module TagInstanceMethods
    def tags
      article_tags = data.tags || data.tag
      
      if article_tags.is_a? String
        article_tags.split(',').map(&:strip)
      else
        Array(article_tags).map(&:to_s)
      end      
    end
  end

  ################
  class TagManipulator < Manipulator
    module ControllerInstanceMethods
      def tags
        @manipulators[:tag].tags
      end
      def tag_resources
        @manipulators[:tag].tag_resources
      end
    end
    class << self
      def enable?(controller)
        controller.extension.options.tag_template
      end
    end
    Middleman::Akcms::Controller.register(:tag, self)
    
    include Contracts
    
    attr_reader :tags, :tag_resources

    def initialize(controller)
      controller.app.ignore @template = controller.options.tag_template
      controller.extend ControllerInstanceMethods

      super(controller)
    end

    
    Contract Array => Array    
    def manipulate_resource_list(resources)
      @tags = Hash.new { |h,k| h[k] = [] }
      @tag_resources = {}
      
      @controller.articles.each {|article|
        article.extend TagInstanceMethods
        article.tags.each {|tag|
          @tag_resources[tag] ||= create_proxy_resource(link(tag), tag_name: tag, articles: [])
          @tag_resources[tag].locals[:articles] << article
          @tags[tag] << article
        }
      }
      resources + @tag_resources.values
    end
    ################################################################
    private
    Contract String => String
    def link(name)
      @controller.options.tag_link % {tag: name}
    end
  end # class
end
