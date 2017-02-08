require 'middleman-core/util/uri_templates'

require 'middleman-akcms/manipulator'
require 'contracts'

module Middleman::Akcms
  class TagManipulator
    ## methods to be extend to each article
    module InstanceMethodsToArticle
      include Contracts

      Contract nil => ArrayOf[String]
      def tags
        article_tags = data.tags || data.tag

        if article_tags.is_a? String
          article_tags.split(',').map(&:strip)
        else
          Array(article_tags).map(&:to_s)
        end      
      end
    end

    ## methods to be extended to controller
    module InstanceMethodsToController
      include Contracts
      
      Contract nil => HashOf[String => ResourceList]
      def tags
        @manipulators[:tag].tags
      end
      Contract nil => HashOf[String => Middleman::Sitemap::Resource]
      def tag_resources
        @manipulators[:tag].tag_resources
      end
    end

    ## this manipulator will be disabled unless template specified
    class << self
      def disable?(controller)
        controller.options.tag_template.nil?
      end
    end
    Middleman::Akcms::Controller.register(:tag, self)
    
    ################
    include Manipulator
    include Contracts
    include Middleman::Util::UriTemplates
    
    attr_reader :tags, :tag_resources

    Contract Controller => Any
    def initialize(controller)
      initialize_manipulator(controller, template: controller.options.tag_template)
      controller.extend InstanceMethodsToController
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      @tags = Hash.new { |h,k| h[k] = [] }
      @tag_resources = {}
      
      @controller.articles.each {|article|
        article.extend InstanceMethodsToArticle
        article.tags.each {|tag|
          @tag_resources[tag] ||= create_proxy_resource(link(tag), locals:
                                                        {tag_name: tag, articles: []})
          @tag_resources[tag].locals[:articles] << article
          @tags[tag] << article
        }
      }
      resources + @tag_resources.values
    end
    
    Contract String => String
    def link(name)
      @controller.options.tag_link % {tag: safe_parameterize(name)}
#      template = uri_template "tags/{tagname}.html"
#      apply_uri_template template, tagname: safe_parameterize(name)
    end
  end # class
end
