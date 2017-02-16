# -*- coding: utf-8 -*-
require 'middleman-akcms/util'

module Middleman::Akcms::Series
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      series_title_template = app.config.akcms[:series][:title_template]

      resources.select {|r| r.path =~ /\/config.yml$/}.each do |config_yml_res|
        yml = YAML::load(config_yml_res.render(layout: false))
        next unless yml['series']

        dir = File.dirname(config_yml_res.path)
        
        series_name = yml['series'] || dir.split('/').last
        
        series_articles = resources.select {|r| r.is_article? && (! r.directory_index?) && File.dirname(r.path) == dir}
        series_articles.each do |article|
          binding.pry
          series_number = article.data.series.try(:number) || ((File.split(article.path).last =~ /^([0-9]+)[_\-\s]/).nil? ? 0 : $1).to_i
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
end
