require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class TagManipulator < Manipulator
    include Contracts
    
    attr_reader :tags

    def create_proxy_resource(name, articles = [])
      template = @controller.options.tag_template
      link = @controller.options.tag_link % {tag: name } 

      Middleman::Sitemap::ProxyResource.new(@controller.app.sitemap, link,
                                            template).tap do |p|
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
  end # class

end
