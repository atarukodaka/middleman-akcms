require 'contracts'

module Middleman::Akcms
  module ResourceContracts
    class Resource
      def self.valid?(val)
        val.is_a?(Middleman::Sitemap::Resource) || val.is_a?(Middleman::Sitemap::ProxyResource)
      end
    end ## class

    class Article
      def self.valid?(val)
        val.is_a?(Middleman::Akcms::Article)
      end
    end
  end  ## module
end
