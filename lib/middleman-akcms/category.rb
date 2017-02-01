require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class CategoryManipulator < Manipulator
    include Contracts

    attr_reader :categories

    Contract String => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(name)
      template = @controller.options.category_template
      link = '%{category}.html' % {category: name }  # link path is NOT configuable

      Middleman::Sitemap::ProxyResource.new(@controller.app.sitemap, link,
                                            template).tap do |p|
        short_name = name.split('/').last
        p.add_metadata(locals: {name: name, display_name: short_name, articles: []})
      end
    end
    def manipulate_resource_list(resources)
      @categories = {}

      @controller.articles.group_by {|a| a.category}.each {|category, articles|
        next if category == ""
        p = create_proxy_resource(category)
        add_category_name(p, category)
        p.add_metadata(locals: {articles: articles})
        @categories[category] = p
      }
      resources + @categories.values.sort_by {|res| res.locals[:name] }
    end
    
    Contract Array => Array
    def _manipulate_resource_list(resources)
      @categories = []

      @controller.articles.map {|res| res.category}
        .uniq.reject {|res| res == ""}.each {|category|
        p = create_proxy_resource(category)
        add_category_name(p, category)
        @categories << p
      }

      ## set articles for each category resources
      @categories.each {|res|
        res.add_metadata(locals: {articles: @controller.articles.select_by(:category, res.locals[:name])})
      }

      resources + @categories.sort {|a, b| a.locals[:name] <=> b.locals[:name]}
    end

    private
    def add_category_name(p, category)
      if txt_res = @controller.app.sitemap.find_resource_by_path(File.join(category, "category_name.txt"))
        p.add_metadata(locals: {display_name: txt_res.render(layout: false).chomp})
      end
    end
  end ## class
end

