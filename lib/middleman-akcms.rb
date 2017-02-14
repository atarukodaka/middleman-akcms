require "middleman-core"
require "middleman-akcms/version"

::Middleman::Extensions.register(:akcms) do
  require 'middleman-akcms/extension'
  ::Middleman::Akcms::Extension
end

Middleman::Extensions.register(:akcms_article) do
  require 'middleman-akcms/article'
  Middleman::Akcms::Article::Extension
end

Middleman::Extensions.register(:akcms_directory_summary) do
  require 'middleman-akcms/directory_summary'
  Middleman::Akcms::DirectorySummary::Extension
end

Middleman::Extensions.register(:akcms_pagination) do
  require 'middleman-akcms/pagination'
  Middleman::Akcms::Pagination::Extension
end

Middleman::Extensions.register(:akcms_archive) do
  require 'middleman-akcms/archive'
  Middleman::Akcms::Archive::Extension
end

Middleman::Extensions.register(:akcms_series) do
  require 'middleman-akcms/series'
  Middleman::Akcms::Series::Extension
end

