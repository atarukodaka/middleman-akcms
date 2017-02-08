require 'contracts'

# summerizer
module Middleman::Akcms
  # base module
  module Summarizer
    include Contracts

    Contract Middleman::Sitemap::Resource, Integer => String
    def summary(resource, length)
      resource.body[0...length]
    end
  end
  class OgaSummarizer
    include Summarizer
    include Contracts
    
    Contract Middleman::Sitemap::Resource, Integer => String
    def summary(resource, length)
      require 'oga'
      begin
        doc = Oga.parse_html(resource.render(layout: false))
        doc.xpath('.//text()').text.delete("\n")[0...length]
      rescue
        "(parser failed)"
      end
    end
  end

  ################
  class Summarize
    include Contracts

    Contract Class => Any
    def initialize(summarizer_klass)
      @summarizer = summarizer_klass.new
    end

    Contract Middleman::Sitemap::Resource, Integer => String
    def summary(resource, length)
      @summarizer.summary(resource, length)
    end
  end
end


