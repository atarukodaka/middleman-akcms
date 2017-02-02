require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class CategoryManipulator < Manipulator
    include Contracts

    attr_reader :categories

    def initialize(controller)
      super(controller)

      @template = controller.options.category_template
    end

    Contract String, Array => Middleman::Sitemap::ProxyResource 
    def create_proxy_resource(name, articles = [])
      Middleman::Sitemap::ProxyResource.new(@sitemap, link(name), @template).tap do |p|
        short_name = name.split('/').last
        p.add_metadata(locals: {
                         name: name, display_name: short_name, articles: articles,
                         parent: nil, children: []})
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
        cat.match(/(.*)\/[^\/]*$/)
        parent_cat = $1

        if parent = @categories[parent_cat]
          res.add_metadata(locals: {parent: parent})
          parent.locals[:children] << res
        end
      }
      resources + @categories.values.sort_by {|res| res.locals[:name] }
    end

    ################
    private
    def add_category_name(p, category)
      catname_filename = File.join(category, "category_name.txt")
      if txt_res = @controller.app.sitemap.find_resource_by_path(catname_filename)
        p.add_metadata(locals: {display_name: txt_res.render(layout: false).chomp})
      end
    end
    Contract String => String
    def link(name)
      '%{category}.html' % {category: name }  # link path is NOT configuable to make parent, children to work
    end

  end ## class
end

