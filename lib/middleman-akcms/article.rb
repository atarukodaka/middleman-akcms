module Middleman::Akcms::Article
  module InstanceMethodsToResource
    def is_article?
      (self.is_a? InstanceMethodsToArticle) ? true : false
    end

    def to_article!
      self.extend InstanceMethodsToArticle
    end
  end  # module
  ################
  module InstanceMethodsToStore
    def articles
      resources.select {|r| r.is_article? }.sort_by {|r| r.date }.reverse
    end
  end  # module
  ################
  module InstanceMethodsToArticle
    include Contracts

    Contract String
    def title
      return data.title.to_s || "(untitled)"
    end

    Contract Date
    def date
      return @_date ||=
        begin
          Date.parse(data.date.to_s)
        rescue ArgumentError
          File.mtime(source_file).to_date || Date.new(1970, 1, 1)
        end
    end

    Contract Array
    def tags
      article_tags = data.tags || data.tag
      
      if article_tags.is_a? String
        article_tags.split(',').map(&:strip)
      else
        Array(article_tags).map(&:to_s)
      end
    end

    Contract Bool
    def published?
      data.published != false
    end
    Contract String
    def body
      render({layout: false})
    end

    def summary(length=nil)
      length ||= @app.config.akcms[:summary_length]
      @app.extensions[:akcms].summarizer.summarize(self, length)
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
    
    Contract Hash, Hash, Or[Proc,nil] => String
    def render(opts={}, locs={}, &block)
      unless opts.has_key?(:layout)
        opts[:layout] = metadata[:options][:layout]
        opts[:layout] = @app.config.akcms[:layout] if opts[:layout].nil? || opts[:layout] == :_auto_layout   ## yet
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

    option :layout, nil # "article"
    
    ## Hooks
    Contract nil => Any
    def after_configuration
      Middleman::Sitemap::Resource.prepend InstanceMethodsToResource
      Middleman::Sitemap::Store.prepend InstanceMethodsToStore
    end

    Contract Middleman::Sitemap::Resource => Bool
    def resource_as_article?(resource)
      return false if resource.ignored? || resource.ext != ".html"
      return false if resource.data.type && (resource.data.type != "article")
      return true
    end
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      used_resources = []
      
      resources.each do |res|
        if resource_as_article?(res)
          res.to_article!
          next unless res.published?
        end
        used_resources << res
      end
      used_resources
    end
  end  ## class  
end # module
