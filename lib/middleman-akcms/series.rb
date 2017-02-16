# -*- coding: utf-8 -*-
require 'middleman-akcms/util'

module Middleman::Akcms::Series
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts

    Contract Middleman::Sitemap::Resource => Integer
    def get_series_number(article)
      series_number = article.data["series-number"] || article.data.series_number
      series_number ||= article.data.series.number if article.data.series.is_a? Hash
      series_number ||= (File.basename(article.path) =~ /^([0-9]+)[_\-\s]/) ? $1.to_i : 1

      return series_number
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      series_title_template = app.config.akcms[:series][:title_template]

      resources.select {|r| r.path =~ /\/config.yml$/}.each do |config_yml_res|
        yml = YAML::load(config_yml_res.render(layout: false))
        next unless yml['series']

        dir_path = File.dirname(config_yml_res.path)
        dir_name = dir_path.split('/').last
        series_name = yml['series'] if yml['series'].is_a? String
        series_name ||= yml['series']['title'] if yml['series'].is_a? Hash
        series_name ||= yml['directory_name'] || dir_name
        
        series_articles = select_articles(resources).select {|article|
          (! article.directory_index?) && File.dirname(article.path) == dir_path}
        series_articles.each do |article|
          series_number = get_series_number(article)
          
          app.logger.debug(" -- series: #{series_name} [#{series_number}] #{article.title}")
          hash = {
            name: series_name,
            number: series_number,
            article_title: article.title,
            articles: series_articles
          }
          title = series_title_template % hash
          article.add_metadata({page: {title: title}, locals: {series: hash}})
        end
      end

      resources
    end
=begin    
    Contract ResourceList => ResourceList
    def __manipulate_resource_list(resources)
      series_articles = []

      select_articles(resources).each do |article|
        if article.data.series
          name = article.metadata.try(:[], :directory).try(:[], :name) || File.dirname(article.path).split('/').last
          # name = ((article.metadata.has_key?(:directory)) ? article.metadata[:directory][:name] : nil) || File.dirname(article.path).split('/').last
          number = (File.split(article.path).last =~ /^([0-9]+)[_\-\s]/).nil? ? 0 : $1.to_i
          
          hash = { name: name, number: number}
          title = apply_title(hash.merge(article_title: article.title))
          article.add_metadata({page: { title: title }, locals: { series: hash }})
          series_articles << article
        end
      end

      series_articles.each do |res|
        res_name = res.locals[:series][:name]
        res.locals[:series][:articles] = series_articles.select {|r|
          res_name == r.locals[:series][:name]
        }
      end
      resources
    end

    Contract Hash => String
    def apply_title(hash)
      @app.config.akcms[:series][:title_template] % hash
    end
  end # class
=end
end
