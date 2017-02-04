require 'middleman-akcms/manipulator'

module Middleman::Akcms
  ################################################################
  class DirectorySummaryManipulator < Manipulator
    include Contracts

    def initialize(controller)
      super(controller)

      @template = controller.options.directory_summary_template
    end

    Contract Array => Array
    def manipulate_resource_list(resources)
      new_resources = []
      index_file = controller.app.config[:index_file]

      @controller.articles.group_by {|a| File.dirname(a.path)}.each {|dir, articles|
        if articles.find {|a| a.path =~ /#{index_file}$/}.nil?
          new_resources << create_proxy_resource("#{dir}/#{index_file}", {articles: articles}).tap {|p|
          }
        end
      }
      (resources + new_resources).map {|p|
        dir_name = nil;
        dir_path = File.dirname(p.path)
        if config_res = @sitemap.find_resource_by_path(File.join(dir_path, "config.yml"))
          yml = YAML::load(config_res.render(layout: false))
          dir_name = yml["display_name"]
        end
        dir_name ||= (((dn = dir_path.split("/").last) == ".") ? nil : dn)
        p.add_metadata(locals: {
                         dir_path: dir_path,
                         dir_name: dir_name
                       })
        p
      }
    end
  end
end


       
