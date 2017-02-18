require 'middleman-akcms/summarize'
require 'middleman-akcms/util'

require 'contracts'

module Middleman::Akcms::DirectorySummary
  class Directory
    attr_reader :path, :name, :index, :articles
    def initialize(path, name: nil, index: nil, articles: [])
      @path = path
      @index = index
      @articles = articles
      @name = name || path.split('/').last
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

    def directory
      #@_directory ||= Directory.new(path)
      @app.extensions[:akcms_directory_summary].directories[File.dirname(path).sub(/^\.$/, '')]
    end
  end  ## module
end

module Middleman::Akcms::DirectorySummary
  module InstanceMethodsToStore
    def index_resource(dir)
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

    #self.resource_list_manipulator_priority = 55
    attr_reader :directories
    
    def manipulate_resource_list(resources)
      @directories = {}
      new_resources = []
      template = app.config.akcms[:directory_summary_template]
      index_file = app.config.index_file
      
      dirs = directories_including_ancestors(resources)
      dirs.each do |path|
        directory_index = resources.find {|r| r.path == Middleman::Util.normalize_path(File.join(path, index_file)) || r.path == "#{path}.html"}
        if directory_index.blank?
          articles = resources.select {|r| r.is_article? && r.path =~ /^#{path}\//}
          md = {locals: {articles: articles}}
          create_proxy_resource(app.sitemap, File.join(path, index_file), template, md).tap do |p|
            directory_index = p
            new_resources << p
          end
        end

        name = if (config_yml = resources.find{|r| r.path == (File.join(path, "config.yml"))})
                 yml = YAML::load(config_yml.render(layout: false))
                 yml["directory_name"].to_s
               end
        @directories[path] = Directory.new(path, name: name, index: directory_index, articles: articles)
      end  ## each dirs
      resources + new_resources
    end
    
    def existing_directories(resources)
      resources.reject(&:ignored?).map {|r| resource_eponymous_dir(r)}.uniq.reject {|path| dir_to_exclude?(path)}
    end
    def directories_including_ancestors(resources)
      ancestor_directories = []

      directories = existing_directories(resources)
      directories.map do |dir|
        dir.split('/').inject("") do |result, part|
          ancestor_directories << Middleman::Util.normalize_path([result, part].join('/'))
          [result, part]
        end
      end
      [*directories, *ancestor_directories].uniq
    end

=begin    
    Contract ResourceList => ResourceList
    def _manipulate_resource_list(resources)
      index_file = app.config.index_file
      new_resources = []      
      empty_directories = {}
      template = app.config.akcms[:directory_summary_template]
      
      directories = get_directories(resources)
      directories.each do |dir, hash|
        app.logger.debug(" -- checking dir: '#{dir}'...")
        
        ## create new dir summary if the dir doesnt have d/i
        if hash[:directory_indices].empty?
          md = {locals: {articles: hash[:articles]}}
          new_resources << create_proxy_resource(app.sitemap, File.join(dir, index_file), template, md)
        end

        ## travsere ancestors
        dir.split('/').inject("") do |result, part|
          dir_path = Middleman::Util.normalize_path([result, part].join('/'))
          app.logger.debug("   -- traversing ancestors: '#{dir_path}'")
          ## neighter in original directories nor new summary above operation
          if (! directories.has_key?(dir_path)) && (! empty_directories.has_key?(dir_path))
            md = {locals: {articles: []}}
            new_resources << empty_directories[dir_path] =
              create_proxy_resource(app.sitemap, File.join(dir_path, index_file), template, md)
          end
          [result, part]
        end
      end
      binding.pry
      resources + new_resources
    end
    
    private
    Contract ResourceList => Hash
    def get_directories(resources)
      ## list up all directories
      directories = {}  ## {directory_indices:, resources:}

      resources.reject {|r| r.ignored?}.group_by {|r|
        #File.dirname(resource_eponymous_path(r)).sub(/^\.$/, '')}.each do |dir_path, list|
        resource_eponymous_dir(r)}.each do |dir_path, list|
        next if dir_to_exclude?(dir_path)
        
        articles = select_articles(list)
        next if articles.empty?
        
        directories[dir_path] = {
          directory_indices: list.select(&:directory_index?),
          articles: articles
        }
      end
      directories
    end
=end
    ## fonts/images/js/css/layouts dir will be excluded
    Contract String => Bool
    def dir_to_exclude?(dir)
      exclude_dir = [ app.config.fonts_dir,  app.config.images_dir,
                      app.config.js_dir,  app.config.css_dir,
                      app.config.layouts_dir]

      regex = Regexp.new("^(#{exclude_dir.join('|')})")
      (regex =~ dir) ? true : false
    end    

    ## e.g. if foo/bar.html and foo/bar/ dir exists, return 'foo/bar'
    def resource_eponymous_dir(resource)
      if resource.eponymous_directory?
        resource.eponymous_directory_path.sub(/\/$/, '')
      else
        File.dirname(resource.path).sub(/^\.$/, '')
      end
    end

=begin    
    ## e.g. if foo/bar.html and foo/bar/ dir exists, return foo/bar/index.html
    Contract Middleman::Sitemap::Resource => String
    def resource_eponymous_path(resource)
      if resource.eponymous_directory?
        resource.eponymous_directory_path + app.config[:index_file]
      else
        resource.path
      end
    end
=end
  end  ## class
end
