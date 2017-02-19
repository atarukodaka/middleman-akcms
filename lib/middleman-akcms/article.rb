require 'active_support/time_with_zone'
require 'active_support/core_ext/time/calculations'

module Middleman::Akcms::Article
  module InstanceMethodsToResource
    include Contracts

    Contract Bool
    def is_article?
      self.is_a? InstanceMethodsToArticle
    end
    Contract Middleman::Sitemap::Resource
    def to_article!
      self.extend InstanceMethodsToArticle
      self
    end
  end  # module

  module InstanceMethodsToStore
    include Contracts

    Contract ResourceList
    def articles
      resources.select {|r| r.is_article? }.sort_by {|r| r.date }.reverse
    end
  end  # module

  module InstanceMethodsToArticle
    include Contracts

    Contract String
    def title
      return data.title.to_s.presence || "(untitled)"
    end

    Contract ActiveSupport::TimeWithZone
    def date
      return @_date if @_date
      fm_date = data.date
      
      @_date = if fm_date.is_a? Time
                 fm_date.in_time_zone
               else
                 Time.zone.parse(fm_date.to_s)
               end
      @_date ||= File.mtime(source_file).in_time_zone || Time.now.in_time_zone
    end

    Contract Bool
    def published?
      data.published != false
    end
    
    Contract Integer => String
    def summary(length=nil)
      length ||= @app.config.akcms[:summarize][:summary_length]
      @app.config.akcms[:summarize][:summarizer].summarize(self, length)
    end

    ## pager
    Contract Hash => Or[Middleman::Sitemap::Resource, nil]
    def prev_article
      @app.sitemap.articles.find {|a| a.date < date}
    end
    Contract Hash => Or[Middleman::Sitemap::Resource, nil]
    def next_article
      @app.sitemap.articles.reverse.find {|a| a.date > date}
    end
    
    Contract String
    def body
      render(layout: false)
    end

    Contract Hash, Hash, Or[Proc,nil] => String
    def render(opts={}, locs={}, &block)
      unless opts.has_key?(:layout)
        opts[:layout] = metadata[:options][:layout]
        opts[:layout] = @app.config.akcms[:layout] if opts[:layout].nil? || opts[:layout] == :_auto_layout
        # Convert to a string unless it's a boolean
        opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
      end
      
      super(opts, locs, &block).to_s
    end
  end  ## module
end

################
module Middleman::Akcms::Article
  class Extension < Middleman::Extension
    include Contracts
    self.resource_list_manipulator_priority = 45
    
    helpers do
      def copyright
        template = "&copy; Copyright(%{years}) %{author}"
        years = sitemap.articles.map {|a| a.date.year}.uniq.sort
        years_str = [years.first, years.last].uniq.join("-")
        #str = (years.size == 1) ? years.first : [years.first, years.last].join('-')
        #"&copy; Copyright(#{str}) #{data.config.site_info.author if data.respond_to?(:config)}"
        template % {years: years_str, author: (data.respond_to?(:config)) ? data.config.site_info.author : ""}
      end
    end
    
    def after_configuration
      Middleman::Sitemap::Resource.prepend InstanceMethodsToResource
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end

    Contract Middleman::Sitemap::Resource => Bool
    def resource_to_be_article?(resource)
      return false if resource.ignored? || resource.ext !~ /\.html?$/
      return false if resource.data.type && (resource.data.type != "article")
      true
    end
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      resources.each do |res|
        res.to_article! if resource_to_be_article?(res)
      end
      resources.reject {|res| res.is_article? && !res.published?}
    end
  end  ## class  
end # module
