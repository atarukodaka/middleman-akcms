require 'middleman-akcms/util'

module Middleman::Akcms::Series
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts

    Contract Middleman::Sitemap::Resource => Integer
    def get_series_number(article)
      series_number = article.data["series-number"] || article.data.series_number
      series_number ||= article.data.series.number if article.data.series.is_a? Hash
      series_number ||= (File.basename(article.path) =~ /^([0-9]+)[_\-\s]/) ? $1.to_i : 0

      return series_number
    end
    
    def get_series_name(yml)
      series_name = yml['series'] if yml['series'].is_a? String
      series_name ||= yml['series']['title'] if yml['series'].is_a? Hash
      series_name ||= yml['directory_name']
    end
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      series_title_template = app.config.akcms[:series][:title_template]

      resources.select {|r| r.path =~ /\/config.yml$/}.each do |config_yml_res|
        yml = YAML::load(config_yml_res.render(layout: false))
        next unless yml['series']

        dir_path = File.dirname(config_yml_res.path)
        dir_name = dir_path.split('/').last
        series_name = get_series_name(yml) || dir_name
        
        series_articles = select_articles(resources).select {|article|
          File.dirname(article.path) == dir_path}
        
        series_articles.each do |article|
          series_number = get_series_number(article)
          
          app.logger.debug(" -- series: #{series_name} [#{series_number}] #{article.title}")
          hash = {
            name: series_name,
            number: series_number,
            article_title: article.title,
            articles: series_articles.reject {|r| r.directory_index?}
          }
          title = if article.directory_index?
                    (article.title.to_s == "") ? series_name : article.title
                  else
                    series_title_template % hash
                  end
          article.add_metadata({locals: {series: hash}, page: {title: title}})
        end
      end

      resources
    end
  end # class
end
