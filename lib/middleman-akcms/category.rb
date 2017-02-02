require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class CategoryManipulator < Manipulator
    include Contracts

    attr_reader :categories

    def create_proxy_resource(name, articles = [])
      template = @controller.options.category_template
      #link = '%{category}.html' % {category: name }  # link path is NOT configuable
      link = 'categories/%{category}.html' % {category: name }

      Middleman::Sitemap::ProxyResource.new(@controller.app.sitemap, link,
                                            template).tap do |p|
        short_name = name.split('/').last
        p.add_metadata(locals: {
                         name: name, display_name: short_name, articles: articles,
                         parent: nil, children: []
                       })
      end
    end

    Contract Array => Array
    def manipulate_resource_list(resources)
      @categories = {}

      @controller.articles.group_by {|a| a.category}.each {|category, articles|
        next if category == ""
        p = create_proxy_resource(category, articles)
        add_category_name(p, category)
        @categories[category] = p
      }

      ## build hierarcy
      @categories.each {|cat, res|
        cat =~ /(.*)\/([^\/]*)$/
        parent_cat, display_cat = $1, $2

        if parent = @categories[parent_cat]
          res.add_metadata(locals: {parent: parent})
          parent.locals[:children] << res
        end
      }
      resources + @categories.values.sort_by {|res| res.locals[:name] }
    end

    private
    def add_category_name(p, category)
      catname_filename = File.join(category, "category_name.txt")
      if txt_res = @controller.app.sitemap.find_resource_by_path(catname_filename)
        p.add_metadata(locals: {display_name: txt_res.render(layout: false).chomp})
      end
    end
  end ## class
end

