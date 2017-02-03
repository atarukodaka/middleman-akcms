require 'middleman-akcms/manipulator'

module Middleman::Akcms
  module ResourceInstanceMethods
    def dir_path
      File.dirname(path)
    end
    def dir_name
      name = nil
      if config_res = @store.find_resource_by_path(File.join(File.dirname(path), "config.yml"))
        yml = YAML::load(config_res.render(layout: false))
        name = yml["display_name"]
      end
      name || File.dirname(path).split("/").last
    end
  end
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
          new_resources << create_proxy_resource("#{dir}/#{index_file}", {articles: articles})
        end
      }
      (resources + new_resources).map {|res| res.extend ResourceInstanceMethods }
    end
  end
end


       
