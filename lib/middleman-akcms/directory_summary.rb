require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class DirectorySummaryManipulator
    class << self
      def disable?(controller)
        controller.extension.options.directory_summary_template.nil?
      end
    end
    Middleman::Akcms::Controller.register(:directory_summary, self)

    ################
    include Manipulator
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    def initialize(controller)
      set_attributes(controller, controller.options.directory_summary_template)
    end
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      new_resources = []
      index_file = controller.app.config[:index_file]
      
      ## create directory summary resources in each dirs
      get_directories().each {|dir, articles|
        if articles.find {|a| a.path =~ /#{index_file}$/}.nil?
          new_resources <<
            create_proxy_resource("#{dir}/#{index_file}", {articles: articles})
        end
      }
      ## put dir info into metadata[:directory] on all resources
      #add_directory_metadata(resources + new_resources)
      (resources + new_resources).map {|res|
        add_directory_metadata(res)
        res
      }
    end
    ################
    private
    ## directories where any articles exist
    Contract nil => Hash
    def get_directories
=begin
      exclude_dirs = ['templates', 'stylesheets', 'javascripts', 'images']
      re = exclude_dirs.join("|")

      dirs = resources.reject {|r| r.ignored || r.path =~ /^#{re}/}.group_by {|r| File.dirname(r.path)}
=end
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

    Contract C::Resource => C::Resource
    def add_directory_metadata(resource)
      dir_name = nil;
      dir_path = File.dirname(resource.path)

      if config_res = @sitemap.find_resource_by_path(File.join(dir_path, "config.yml"))
        yml = YAML::load(config_res.render(layout: false))
        dir_name = yml["display_name"]
      end
      dir_name ||= (((dn = dir_path.split("/").last) == ".") ? nil : dn)
#      {directory: { path: dir_path, name: dir_name}}
      resource.tap {|r| r.add_metadata(directory: { path: dir_path, name: dir_name})}
    end
  end ## class
end


       
