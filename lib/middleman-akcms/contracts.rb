require 'contracts'

module Middleman::Akcms
  module C
    class Resource
      def self.valid?(val)
        val.is_a?(Middleman::Sitemap::Resource)
      end
    end ## class
  end
end

  module Contracts
=begin
    class Resource
      def self.valid?(val)
        val.is_a?(Middleman::Sitemap::Resource)
      end
    end ## class
    
    class Article
      def self.valid?(val)
        val.is_a?(Middleman::Akcms::Article)
      end
    end  ## module
=end
  end

