require 'contracts'

module Middleman::Akcms
  module Contracts
  #  module ResourceContracts
    class Resource
      def self.valid?(val)
        val.is_a?(Middleman::Sitemap::Resource)
      end
    end ## class

=begin
    class ProxyResource
      def self.valid?(val)
        val.is_a?(Middleman::Sitemap::ProxyResource)
      end
    end ## class

    Proxy = ProxyResource
=end
    class Article
      def self.valid?(val)
        val.is_a?(Middleman::Akcms::Article)
      end
    end
  end  ## module
end
