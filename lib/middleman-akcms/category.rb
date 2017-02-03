require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class CategoryManipulator < Manipulator
    include Contracts

    attr_reader :categories

    def initialize(controller)
      super(controller)

      @template = controller.options.category_template
    end

    Contract Array => Array
    def manipulate_resource_list(resources)
      @categories = {}

      @controller.articles.group_by {|a| a.category}.each {|category, articles|
        next if category == ""

        locals = {
          category_name: category,
          display_name: category.split('/').last,
          articles: articles
        }
        
        p = create_proxy_resource(link(category), locals)
        p.add_metadata(tree: { parent: nil, children: [] })
        add_category_name(p, category)
        @categories[category] = p
      }

      ## build hierarcy
      @categories.each {|cat, res|
        cat.match(/(.*)\/[^\/]*$/)
        parent_cat = $1

        if parent = @categories[parent_cat]
          res.add_metadata(tree: {parent: parent})
          #parent.locals[:children] << res
          parent.metadata[:tree][:children] << res
        end
      }
      resources + @categories.values.sort_by {|res| res.locals[:category_name] }
      # resources
    end

    ################
    private
    def add_category_name(p, category)
      require 'yaml'
      config_res = @sitemap.find_resource_by_path(File.join(category, "config.yml"))
      if config_res
        yml = YAML::load(config_res.render(layout: false))
        p.add_metadata(locals: {display_name: yml["category_name"]})
      end
    end
=begin
    def _add_category_name(p, category)
      catname_filename = File.join(category, "category_name.txt")
      if txt_res = @controller.app.sitemap.find_resource_by_path(catname_filename)
        p.add_metadata(locals: {display_name: txt_res.render(layout: false).chomp})
      end
    end
=end
    Contract String => String
    def link(name)
      #'%{category}.html' % {category: name }  # link path is NOT configuable to make parent, children to work
      '%{category}/index.html' % {category: name}
    end

  end ## class
end

