require 'middleman-akcms/manipulator'

module Middleman::Akcms
  ## methods to be extend to Middleman::Sitemap::Resources for each article
  module Article
    include Contracts
    
    ## let Middleman::Sitemap::Resources have .controller method
    def self.extended(base)
      base.class.send(:attr_accessor, :controller)
    end
    
    Contract String
    def title
      (data.title || "(untitled)").to_s
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
    
    ## pager
    Contract Hash => Or[Middleman::Sitemap::Resource, nil]
    def prev_article
      @controller.articles.find {|a| a.date < date}
    end
    Contract Hash => Or[Middleman::Sitemap::Resource, nil]
    def next_article
      @controller.articles.reverse.find {|a| a.date > date}
    end

    Contract Integer => String
    def summary(length=nil)
      controller.summary(self, length)
    end
    
    Contract KeywordArgs[:layout => Or[String, Symbol, nil]] => String
    def body
      render(layoout: false)
    end

    Contract Hash, Hash, Func => String
    ## called automatically from middleman (this code copied from mm-blog)
    def render(opts={}, locs={}, &block)
      unless opts.has_key?(:layout)
        opts[:layout] = metadata[:options][:layout]
        opts[:layout] = controller.options[:layout] if opts[:layout].nil? || opts[:layout] == :_auto_layout
        
       # Convert to a string unless it's a boolean
        opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
      end
      super(opts, locs, &block)
    end
  end ## class
end
################################################################
module Middleman::Akcms
  class ArticleManipulator
    Middleman::Akcms::Controller.register(:article, self)
    ################
    include Manipulator
    include Contracts
    
    attr_reader :articles

    Contract Controller => Any
    def initialize(controller)
      initialize_manipulator(controller)
      @articles = []
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      list = []
      
      used_resources = []
      resources.each {|res|
        ## ignored res doesnt bother
        if res.ignored?
          used_resources << res
          next
        end

        ## ".html" regarded as 'article'
        if res.ext == ".html" && !(res.data.type && res.data.type != "article")
          article = convert_to_article(res)          
          next if article.data.published == false
          list << article
        end
        used_resources << res
      }
      @articles = list.sort_by(&:date).reverse

      return used_resources
    end
    
    private
    Contract Middleman::Sitemap::Resource => Article
    def convert_to_article(resource)
      return resource if resource.is_a?(Article)  # return if its already Article class

      resource.tap {|r|
        r.extend Article
        r.controller = @controller
      }
    end
  end  ## class
end

