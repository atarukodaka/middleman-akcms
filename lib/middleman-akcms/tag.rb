require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class TagManipulator < Manipulator
    include Contracts
    
    attr_reader :tags

    def initialize(controller)
      super(controller)

      @template = controller.options.tag_template
    end

    Contract String, Array => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(name, articles = [])
      Middleman::Sitemap::ProxyResource.new(@sitemap, link(name),@template).tap do |p|
        p.add_metadata(locals: {name: name, articles: articles})
      end
    end

    Contract Array => Array    
    def manipulate_resource_list(resources)
      @tags = {}

      @controller.articles.each {|article|
        article.tags.each {|tag|
          # @tags[tag] ||= []
          @tags[tag] ||= create_proxy_resource(tag, [])
          @tags[tag].locals[:articles] << article
        }
      }
      resources + @tags.values
    end
    ################################################################
    private
    Contract String => String
    def link(name)
      @controller.options.tag_link % {tag: name}
    end

  end # class

end
