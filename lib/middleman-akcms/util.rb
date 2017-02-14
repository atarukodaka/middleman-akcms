require 'contracts'

module Middleman::Akcms::Util
  include Contracts

  Contract ResourceList => Or[ResourceList, nil]
  def select_articles(resources)
    resources.select {|r| r.is_article? }.sort_by {|a| a.date}.reverse
  end
end  ## module
