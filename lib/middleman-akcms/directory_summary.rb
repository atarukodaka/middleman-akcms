require 'middleman-akcms/summarize'
require 'middleman-akcms/util'

require 'contracts'

module Middleman::Akcms::DirectorySummary
  class Directory
    include Contracts
    
    attr_reader :path

    Contract String, KeywordArgs[:sitemap => Middleman::Sitemap::Store] => Any
    def initialize(path, sitemap: nil)
      @path = path.sub(/^\.$/, '')
      @sitemap = sitemap || raise("sitemap required")
      @name = nil
      @index = nil
      @articles = []
    end

    Contract String
    def name
      @name ||= if (config_yml = @sitemap.find_resource_by_path(File.join(path, "config.yml")))
                  yml = YAML::load(config_yml.render(layout: false))
                  yml["directory_name"].to_s
                end || @path.split('/').last
    end

    Contract Or[Middleman::Sitemap::Resource, nil]
    def index
      @sitemap.find_directory_index(path)
    end

    Contract ResourceList
    def articles
      @index.children.select {|r| r.is_article? && !r.directory_index?}
    end
  end  ## class

  module InstanceMethodsToResource
    include Contracts
    
    ## foo/bar.html as parent of foo/bar/baz/index.html
    Contract nil => Or[Middleman::Sitemap::Resource, nil]
    def parent
      ret = super
      return ret if ret
      parts = File.dirname(path).split('/')
      parts.pop
      extname = File.extname(@app.config.index_file)
      @store.find_resource_by_destination_path(File.join(parts) + extname)
    end

    Contract Middleman::Akcms::DirectorySummary::Directory
    def directory
      @_directory ||= Directory.new(File.dirname(path), sitemap: @store)
    end
  end  ## module
end

module Middleman::Akcms::DirectorySummary
  module InstanceMethodsToStore
    include Contracts

    Contract String => Or[Middleman::Sitemap::Resource, nil]
    def find_directory_index(dir = "")
      dir = Middleman::Util.normalize_path(dir).sub(/\/$/, '')
      @app.sitemap.find_resource_by_path(dir + "/"  + @app.config.index_file) ||
        @app.sitemap.find_resource_by_path(dir + File.extname(@app.config.index_file))
    end
  end ## module
end

################
module Middleman::Akcms::DirectorySummary
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts

    def after_configuration
      Middleman::Sitemap::Resource.prepend InstanceMethodsToResource
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end

    Contract String, KeywordArgs[:resources => ResourceList, :index_file => String] => Or[Middleman::Sitemap::Resource, nil]
    def find_directory_index(path, resources: [], index_file: "index.html")
      resources.find {|r| r.path == Middleman::Util.normalize_path(File.join(path, index_file)) || r.path == "#{path}.html"}
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      new_resources = []
      template = app.config.akcms[:directory_summary_template]
      index_file = app.config.index_file
      
      dirs = directories_including_ancestors(resources)
      dirs.each do |path|
          directory_index = find_directory_index(path, resources: resources, index_file: index_file)
        if directory_index.blank?
          articles = resources.select {|r| r.is_article? && r.path =~ /^#{path}\/[^\/]*$/}
          md = {locals: {articles: articles}}
          create_proxy_resource(app.sitemap, File.join(path, index_file), template, md).tap do |p|
            new_resources << p
          end
        end
      end  ## each dirs
      resources + new_resources
    end
    
    Contract ResourceList => ArrayOf[String]
    def directories_including_ancestors(resources)
      ancestor_directories = []

      existing_directories = resources.reject(&:ignored?).map {|r|
        resource_eponymous_dir(r)}.uniq.reject {|path| dir_to_exclude?(path)}
      existing_directories.map do |dir|
        dir.split('/').inject("") do |result, part|
          ancestor_directories << Middleman::Util.normalize_path([result, part].join('/'))
          [result, part]
        end
      end
      [*existing_directories, *ancestor_directories].uniq
    end

    ## fonts/images/js/css/layouts dir will be excluded
    Contract String => Bool
    def dir_to_exclude?(dir)
      exclude_dir = [ app.config.fonts_dir,  app.config.images_dir,
                      app.config.js_dir,  app.config.css_dir,
                      app.config.layouts_dir]

      regex = Regexp.new("^(#{exclude_dir.join('|')})")
      (regex =~ dir) ? true : false
    end    

    ## e.g. if foo/bar.html given and foo/bar/ dir exists, return 'foo/bar'
    Contract Middleman::Sitemap::Resource => String
    def resource_eponymous_dir(resource)
      if resource.eponymous_directory?
        resource.eponymous_directory_path.sub(/\/$/, '')
      else
        File.dirname(resource.path).sub(/^\.$/, '')
      end
    end
  end  ## class
end
