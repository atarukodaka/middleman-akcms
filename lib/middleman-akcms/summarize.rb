require 'contracts'

module Middleman::Akcms
  ## base module to be included
  module Summarizer
    include Contracts

    Contract Middleman::Sitemap::Resource, Integer => String
    def summarize(resource, length)
       resource.render({layout: false})[0...length]
    end
  end

  ## simple summarizer class
  class SimpleSummarizer
    include Summarizer
  end
  ## summarizer class using Oga
  class OgaSummarizer
    include Summarizer
    include Contracts
    
    Contract Middleman::Sitemap::Resource, Integer => String
    def summarize(resource, length)
      require 'oga'
      begin
        doc = Oga.parse_html(resource.render(layout: false))
        doc.xpath('.//text()').text.delete("\n")[0...length]
      rescue
        "(parser failed)"
      end
    end
  end
end

