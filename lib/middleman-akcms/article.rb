require 'middleman-akcms/manipulator'

module Middleman::Akcms
  module Article
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
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
      return @_date if @_date
      return @_date = begin; Date.parse(data.date.to_s); rescue ArgumentError; end ||
        File.mtime(source_file).to_date || Date.new(1970, 1, 1)
    end
    
    Contract Integer => String
    def summary(length=nil)
      require 'oga'
      length ||= controller.options.summary_length || 250
      begin
        doc = Oga.parse_html(render(layout: false))
        doc.xpath('.//text()').text.delete("\n")[0..length]
      rescue
        "(parser failed)"
      end
    end

    ## pager
    Contract Hash => Or[C::Resource, nil]
    def prev_article(options = {})
      @controller.articles.find {|a| a.date < date}
    end
    Contract Hash => Or[C::Resource, nil]
    def next_article(options = {})
      @controller.articles.reverse.find {|a| a.date > date}
    end

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
  class ArticleManipulator < Middleman::Akcms::Manipulator
    class << self
      def enable?(controller)
        true
      end
    end
    Middleman::Akcms::Controller.register(:article, self)
    ################
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    attr_reader :articles
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      articles = []

      used_resources = []
      resources.each {|res|
        ## ignored res doesnt bother
        if res.ignored?
          used_resources << res
          next
        end

        ## ".html" regarded as 'article'
        if res.ext == ".html"
          article = convert_to_article(res)
          next if article.data.published == false
          articles << article
        end
        used_resources << res
      }
      @articles = articles.sort_by(&:date).reverse

      return used_resources
    end
    
    private
    Contract C::Resource => C::Article
    def convert_to_article(resource)
      return resource if resource.is_a?(Article)  # return if its already Article class

      resource.tap {|r|
        r.extend Article
        r.controller = @controller
      }
    end
  end  ## class
end

