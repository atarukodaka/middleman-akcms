## TODO
- rubygems
- archives の作り再考
- シリーズ機能
- pager: within_category を config option へ
- pagination の作り再考
- metadata{} は read only
- add_metadata で値を入れる
- summary_template.erb

## master
### 0.0.1
- カテゴリの階層表現
- tag サポート
- 複数tagのサポート
  - article: tags
  - tagmanipulator
- res.metadata は readonly なので変更するときは add_metadata すること
- tagはとりあえずサポートしないことに
- date: がない場合の扱い
  -- ソースのmtimeを取る。それでもだめなら Date.new
- pagination サポート
  - res.data.pagination
  - locals: page_articles, paginator
- source/foo/category_name.txt にカテゴリ表示名を入れられる
- directory index 対応チェック
- tags
- pagination: <<,1,2,3,>>
- bootstrap, js CDN
- breadcrump: pagination のとき
- publishable: done
- layout構成整理: done
- pagination: 長いとき
- paginator feature: done
- categories, archivies, tags を配列からハッシュに: done
- category: parent, children: locals -> tree
- source/*/config.yml category_name: foo でカテゴリ表示名を設定
- category link を game/wot.html から game/wot/index.html に変更
- category から index summary ？
- category_name.txt -> config.yml
