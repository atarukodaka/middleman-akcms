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
    Contract Array => Array
    def manipulate_resource_list(resources)
      @categories = []

      @controller.articles.map {|res| res.category}
        .uniq.reject {|res| res == ""}.each {|category|
        @categories <<  create_proxy_resource(category).tap {|p|
          txt_res = @controller.app.sitemap.find_resource_by_path(File.join(category, "category_name.txt"))
          if txt_res
            p.add_metadata(locals: {display_name: txt_res.render(layout: false).chomp})
          end
        }
      }

      ## set children for each category resources
      @categories.each {|res|
        res.add_metadata(locals: {articles: @controller.articles.select_by(:category, res.locals[:name])})
      }

      resources + @categories.sort {|a, b| a.locals[:name] <=> b.locals[:name]}
    end
  end ## class
end

