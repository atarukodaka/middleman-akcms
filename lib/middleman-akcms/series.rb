require 'middleman-akcms/util'

module Middleman::Akcms::Series
  class Extension < Middleman::Extension
    include Middleman::Akcms::Util
    include Contracts


    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      series_title_template = app.config.akcms[:series][:title_template]
      selected_articles = []
      
      select_articles(resources).each do |article|
        if (n = get_series_number(article))
          article.add_metadata(locals: {series: {number: n, name: dirname(article.path)}})
          selected_articles << article
        end
      end
      selected_articles.group_by {|a| a.locals[:series][:name]}.each do |dir_path, articles|
        series_name =dir_path.split('/').last
        articles.sort_by! {|a| a.locals[:series][:number]}

        if (index_res = app.sitemap.find_resource_by_path(File.join(dir_path, app.config.index_file)))
          series_name = index_res.data.title if index_res.data.present?
          index_res.add_metadata(locals: {articles: articles})
        end
        articles.each do |article|
          title = series_title_template % article.locals[:series].merge({name: series_name, article_title: article.title})

          article.add_metadata({page: {title: title},
                                 locals: {series: {name: series_name, articles: articles}}})
        end
      end
      resources
    end    
    
    # retrieve series number from resource:
    #   1. 'series-number: 2' from the frontmatter
    #   2. 'series:\n  number: 2' from the frontmatter
    #   3. from the filename like '2_xxxx.html' 
    Contract Middleman::Sitemap::Resource => Or[Integer,nil]
    def get_series_number(article)
      series_number = article.data["series-number"] || article.data.series_number ||
        (article.data.series.number if article.data.series.is_a? Hash) || 
        ((File.basename(article.path) =~ /^([0-9]+)[_\-\s]/) ? $1.to_i : nil)
    end

    # retrieve series name from the yml:
    #  1. 'series: foo'
    #  2. "series:\n  name: foo"
    #  3. "directory_name: foo"
    Contract Hash => Or[String, nil]
    def _get_series_name(yml)
      series_name = yml['series'] if yml['series'].is_a? String
      series_name ||= yml['series']['name'] if yml['series'].is_a? Hash
      return series_name ||= yml['directory_name']  # rubocop:disable Lint/UselessAssignment
    end
    
    Contract ResourceList => ResourceList
    def _manipulate_resource_list(resources)
      series_title_template = app.config.akcms[:series][:title_template]

      resources.select {|r| r.path =~ /\/config.yml$/}.each do |config_yml_res|
        yml = YAML::load(config_yml_res.render(layout: false))
        next unless yml['series']

        dir_path = dirname(config_yml_res.path)
        dir_name = dir_path.split('/').last
        series_name = get_series_name(yml) || dir_name

        series_articles = select_articles(resources).select {|res| dirname(res.path) == dir_path}

        series_articles.each do |article|
          series_number = get_series_number(article)
          
          app.logger.debug(" -- series: #{series_name} [#{series_number}] #{article.title}")
          hash = {
            name: series_name,
            number: series_number,
            article_title: article.title,
            articles: series_articles,
          }
          title = series_title_template % hash
          article.add_metadata({locals: {series: hash}, page: {title: title}})
        end
        index_file = app.config.index_file
        ext = File.extname(index_file)
        if (index_res = resources.find {|r| r.path == File.join(dir_path, index_file) || r.path == dir_path + ext })
          index_res.add_metadata({locals: {series: {articles: series_articles}},
                                   page: {title: index_res.data.title || series_name}})
        end
      end
      resources
    end
  end # class
end
