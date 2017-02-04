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
      ## directories where any articles exist
      new_resources = []
      index_file = controller.app.config[:index_file]

      ## create dir summary resources in each dirs
      get_directories().each {|dir, articles|
      #      dirs.merge(new_dirs).each {|dir, articles|
        if articles.find {|a| a.path =~ /#{index_file}$/}.nil?
          new_resources <<
            create_proxy_resource("#{dir}/#{index_file}", {articles: articles})
        end
      }

      ## put dir info into metadata[:directory] on all resources
      add_metadata_directory(resources + new_resources)
    end
    ################################################################
    private
    Contract nil => Hash
    def get_directories
      dirs = @controller.articles.group_by {|a| File.dirname(a.path)}

      ## find parent directories where any articles doesnt exist
      new_dirs = {}
      dirs.each {|dir, _articles|
        d = File.dirname(dir)
        while d != "."  # "." means top dir
          new_dirs[d] = [] if ! dirs.has_key? d
          d = File.dirname(d)
        end
      }
      return dirs.merge(new_dirs)
    end

    Contract Array => Array
    def add_metadata_directory(resources)
      resources.map {|res|
        dir_name = nil;
        dir_path = File.dirname(res.path)
        if config_res = @sitemap.find_resource_by_path(File.join(dir_path, "config.yml"))
          yml = YAML::load(config_res.render(layout: false))
          dir_name = yml["display_name"]
        end
        dir_name ||= (((dn = dir_path.split("/").last) == ".") ? nil : dn)
        res.tap {|r| r.add_metadata(directory: { path: dir_path, name: dir_name})}
      }
    end
  end ## class
end


       
