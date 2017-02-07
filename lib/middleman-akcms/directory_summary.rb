require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class DirectorySummaryManipulator
    ## this manipulator will be disabled unless template specified
    class << self
      def disable?(controller)
        controller.extension.options.directory_summary_template.nil?
      end
    end
    Middleman::Akcms::Controller.register(:directory_summary, self)

    ################
    include Middleman::Util                   # normalize_path
    include Manipulator
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    def initialize(controller)
      set_attributes(controller, controller.options.directory_summary_template)
    end
    
    def manipulate_resource_list(resources)
      index_file = controller.app.config[:index_file]
      new_resources = []
      
      dirs = @controller.articles.group_by {|a| File.dirname(a.path).sub(/^\.$/, "")}
      dirs.each do |dir, articles|
        dir.split('/').inject("") do |result, part|
          dir_index_fname = normalize_path(File.join(result, part, index_file))
          ## if directory index doesnt exists, create and add it into new resource
          if (resources + new_resources).find {|res| res.path == dir_index_fname}.nil?
            new_resources <<
              create_proxy_resource(dir_index_fname, locals: {articles: articles})
          end
          [result, part]
        end
      end
      (resources + new_resources).map {|res| add_directory_metadata(res) }
    end

    Contract C::Resource => C::Resource
    def add_directory_metadata(resource)
      home_dir_name = "Home"  # yet: to be config ??
      dir_path = File.dirname(resource.path)
      dir_name = dir_path.split('/').last.sub(/^\./, home_dir_name)
      
      ## if "display_name: specified in config.yml, use it as directory 'name'
      if config_res = @sitemap.find_resource_by_path(File.join(dir_path, "config.yml"))
        yml = YAML::load(config_res.render(layout: false))
        dir_name = yml["display_name"]
      end
      
      resource.add_metadata(directory: { path: dir_path, name: dir_name})
      return resource
    end
  end ## class
end


       
