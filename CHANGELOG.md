## TODO
- rubygems

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
- archives, caregories, tags はハッシュの方がいい？
  - 配列で。
- source/foo/category_name.txt にカテゴリ表示名を入れられる
- directory index 対応チェック
- tags
- pagination: <<,1,2,3,>>
- bootstrap, js CDN
- breadcrump: pagination のとき
- publishable
- layout構成整理
- pagination: 長いとき
- paginator feature
