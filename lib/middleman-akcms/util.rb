require 'contracts'

module Middleman::Akcms::Util
  include Contracts

  Contract ResourceList => Or[ResourceList, nil]
  def select_articles(resources)
    #resources.select {|r| r.is_article? }.sort_by {|a| a.date}.reverse
    resources.select(&:is_article?).sort_by(&:date).reverse
  end

  Contract Middleman::Sitemap::Store, String, String, Hash => Middleman::Sitemap::ProxyResource
  def create_proxy_resource(sitemap, link, template, metadata = {})
    sitemap.app.logger.debug("  * new resource added: #{link}")
    Middleman::Sitemap::ProxyResource.new(sitemap, link, template).tap do |p|
      p.add_metadata(metadata)
    end
  end

  Contract String => String
  def dirname(path)
    File.dirname(path).sub(/^\.$/, '')
  end
end  ## module
