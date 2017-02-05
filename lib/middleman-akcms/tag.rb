require 'middleman-akcms/manipulator'

module Middleman::Akcms
  module TagInstanceMethods
    ## tag
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
    class << self
      def enable?(controller)
        controller.extension.options.tag_template
      end
    end
    Middleman::Akcms::Controller.register(:tag, self)
    
    include Contracts
    
    attr_reader :proxy_resources, :tags

    def initialize(controller)
      @template = controller.options.tag_template
      @tags = Hash.new { |h,k| h[k] = [] }
      def controller.tags
        @manipulators[:tag].tags
      end
      super(controller)
    end

    Contract Array => Array    
    def manipulate_resource_list(resources)
      @proxy_resources = {}
      
      @controller.articles.each {|article|
        article.extend TagInstanceMethods
        article.tags.each {|tag|
          @proxy_resources[tag] ||= create_proxy_resource(link(tag), tag_name: tag, articles: [])
          @proxy_resources[tag].locals[:articles] << article
          @tags[tag] << article
        }
      }
      resources + @proxy_resources.values
    end
    ################################################################
    private
    Contract String => String
    def link(name)
      @controller.options.tag_link % {tag: name}
    end
  end # class
end
