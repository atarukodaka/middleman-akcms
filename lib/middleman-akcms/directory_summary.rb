require 'middleman-akcms/summarize'
require 'contracts'

module Middleman::Akcms::DirectorySummary
  module InstanceMethodsToResource
    include Contracts
    
    ## foo/bar/baz/index.html => foo/bar.html as parent
    Contract nil => Or[Middleman::Sitemap::Resource, nil]
    def parent
      ret = super
      return ret if ret
      parts = File.dirname(path).split('/')
      parts.pop
      extname = File.extname(@app.config[:index_file])
      @store.find_resource_by_destination_path(File.join(parts) + extname)
    end
  end  ## module
end

################
module Middleman::Akcms::DirectorySummary
  class Extension < Middleman::Extension
    include Contracts

    Contract nil => Any
    def after_configuration
      Middleman::Sitemap::Resource.prepend InstanceMethodsToResource
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      index_file = app.config[:index_file]
      new_resources = []      
      empty_directories = {}
      
      directories = get_directories(resources.select {|r| r.is_article?})

      directories.each do |dir, hash|
        app.logger.debug(" -- checking dir: '#{dir}'...")
        # add directory metadata for each resources
        hash[:articles].each do |res|
          res.add_metadata(directory: {name: dirname_by_path(dir), path: dir})
        end
        
        # create new dir summary if the dir doesnt have d/i
        if hash[:directory_indices].empty?
          md = create_metadata(path: dir, articles: hash[:articles])
          new_resources << create_proxy_resource(File.join(dir, index_file), md)
        end

        # travsere ancestors
        dir.split('/').inject("") do |result, part|
          dir_path = Middleman::Util.normalize_path([result, part].join('/'))
          app.logger.debug("   -- traversing ancestors: '#{dir_path}'")
          if ! directories.has_key?(dir_path)
            empty_directories[dir_path] ||= create_proxy_resource(File.join(dir_path, index_file), create_metadata(path: dir_path, articles: []))
          end
          [result, part]
        end
      end
      resources + new_resources + empty_directories.values
    end
    
    private

    Contract ResourceList => Hash
    def get_directories(articles)
      ## list up all directories
      directories = {}  ## {directory_indices:, articles:}
      
      articles.group_by {|r| dirname(resource_eponymous_path(r))}.each do |dir_path, list|
        next if dir_to_exclude?(dir_path)
        directories[dir_path] = {
          directory_indices: list.select {|a| a.directory_index?},
          articles: list}
      end
      directories
    end

    Contract String, Hash => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(link, metadata = {})
      app.logger.debug(" -- new resource added: #{link} with md: #{metadata}")
      template = app.config.akcms[:directory_summary_template]
      Middleman::Sitemap::ProxyResource.new(app.sitemap, link, template).tap do |p|
        p.add_metadata(metadata)
      end
    end

    Contract String => String
    def dirname_by_path(path)
      if (config_yml = @app.sitemap.find_resource_by_path(File.join(path, "config.yml")))
        yml = YAML::load(config_yml.render(layout: false))
        yml["display_name"]  ## yet
      else
        path.split('/').last
      end.to_s
    end
    Contract KeywordArgs[:path => String, :articles => ResourceList] => Hash
    def create_metadata(path: "", articles: [])
      {
        directory: { name: dirname_by_path(path), path: path},
        locals: {articles: articles}
      }
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

    ## e.g. if foo/bar.html and foo/bar/ dir exists, return foo/bar/index.html
    Contract Middleman::Sitemap::Resource => String
    def resource_eponymous_path(resource)
      if resource.eponymous_directory?
        resource.eponymous_directory_path + app.config[:index_file]
      else
        resource.path
      end
    end

    ## if its root dir, return '' instead of '.' (which is given by std lib)
    Contract String => String
    def dirname(path)
      File.dirname(path).sub(/^\.$/, '')
    end
  end  ## class
end
