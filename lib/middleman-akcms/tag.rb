require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class TagManipulator < Manipulator
    include Contracts
    
    attr_reader :tags

    def initialize(controller)
      super(controller)

      @template = controller.options.tag_template
    end

    Contract Array => Array    
    def manipulate_resource_list(resources)
      @tags = {}

      @controller.articles.each {|article|
        article.tags.each {|tag|
          @tags[tag] ||= create_proxy_resource(:name, tag, articles: [])
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
