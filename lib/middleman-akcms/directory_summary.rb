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

      dirs = @controller.articles.group_by {|a| File.dirname(a.path)}

      #require 'pry-byebug'

      new_dirs = {}
      dirs.each {|dir, _articles|
        d = File.dirname(dir)
        while d != "."
          #new_dirs[d] = [create_proxy_resource("#{dir}/dummy.html")] if ! dirs.has_key? d
          new_dirs[d] = [] if ! dirs.has_key? d
          d = File.dirname(d)
        end
      }
      
      dirs.merge! new_dirs

      dirs.each {|dir, articles|
        if articles.find {|a| a.path =~ /#{index_file}$/}.nil?
          new_resources << create_proxy_resource("#{dir}/#{index_file}", {articles: articles}).tap {|p|
            p.add_metadata(page: {pagination: nil}) if articles.empty?
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
        p.add_metadata(directory: {
                         path: dir_path,
                         name: dir_name
                       })
        p
      }
    end
  end
end


       
