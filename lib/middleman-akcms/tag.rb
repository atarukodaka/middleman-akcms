require 'middleman-akcms/util'
require 'contracts'

module Middleman::Akcms::Article
  module InstanceMethodsToArticle
    Contract Array

    ## this will be extended to article on Middleman::Akcms::Article.to_article!
    def tags
      article_tags = data.tags || data.tag
      
      if article_tags.is_a? String
        article_tags.split(',').map(&:strip)
      else
        Array(article_tags).map(&:to_s)
      end      
    end
  end ## module
end

module Middleman::Akcms::Tag
  module InstanceMethodsToStore
    include Contracts

    Contract HashOf[String => Middleman::Sitemap::ProxyResource]
    def tags
      @app.extensions[:akcms_tag].tags
    end
  end  ## module
end

module Middleman::Akcms::Tag
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts
    
    attr_reader :tags

    def after_configuration
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      @tags = {}
      template = app.config.akcms[:tag][:template]
      
      select_articles(resources).each {|article|
        article.tags.each {|tag|
          @tags[tag] ||= create_proxy_resource(app.sitemap, link_path(tag), template, locals: {tag_name: tag, articles: []})
          @tags[tag].locals[:articles] << article
        }
      }
      resources + @tags.values
    end
    private
    Contract String => String
    def link_path(name)
      
      app.config.akcms[:tag][:link] % {tag: Middleman::Util::UriTemplates.safe_parameterize(name)}
    end
  end # class
end
