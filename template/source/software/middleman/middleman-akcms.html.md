---
title: middleman-akcms 文書管理拡張機能のご紹介
date: 2017-01-27
---

## 概要
middleman のディレクトリごとのサマリーを自動生成する文書管理システムを拡張機能として作ってみました。

[akcms - Ataru Kodaka Content Management System - atarukodaka/middleman-akcms](https://github.com/atarukodaka/middleman-akcms)

動作サンプルはこちら：[Home \- Ataru Kodaka Site](http://atarukodaka.github.io/)

スナップショット：

<div>
<a href="/images/middleman-akcms-snapshot.png"><img src="/images/middleman-akcms-snapshot.png" alt="スナップショット" style="max-width: 70%"></a>
</div>

foo/bar/baz.html を作成すると、foo/bar/index.html, foo/index.html, index.html といったディレクトリサマリーページを自動生成します。これにより、どのリソースからも parent, children でたどることができるようになります。

その他、月別アーカイブ、タグ、ペジネーション、breadcrumbなどをサポートします。
付属テンプレートでは bootstrap3をサポートします。

## インストールと使いかた
middleman4 を入れた状態で、テンプレートを指定してプロジェクトを作ります

```sh
$ middleman init proj --template git@github.com:atarukodaka/middleman-akcms.git
```

後は通常どおりにprojに入ってsource/ 以下お好きなようにファイルを作って中身を書き build や server 回します。

### 設定
#### config.rb
config.rb にて :akcms を activate し、各種設定をします。

```ruby
activate :akcms do |akcms|
  akcms.layout = "article"

  akcms.directory_summary_template = "templates/directory_summary_template.html"
  akcms.archive_month_template = "templates/archive_template.html"
  akcms.tag_template = "templates/tag_template.html"
  akcms.pagination_per_page = 10
end
```

使うレイアウトやテンプレート群を指定してください。
ペジネーションのデフォルト表示数/頁も指定できますが、
記事ごとに指定することもできます（後述）。

## 設計と機能
### 記事 / Article

以下の特徴を持ったリソースは、article とみなされ：

- ignored でないもの
- 拡張子が .html あるいは .htm のもの
- フロントマターで type: summary などと、'article' 以外のものが明示的に指定されていないもの

以下のメソッドを持ちます：

- title：記事タイトル
- date：日付(TimeWithZoneクラス）。date: フロントマターあるいは更新日時から生成
- summary：サマリー表示
- published?：出力するか。published: false でなければ真
- prev_article：次の記事
- next_article：前の記事
- body：記事本文（レイアウト不使用）

そして、Middleman::Sitemap::Store クラス(sitemapオブジェクトが生成される）には、以下のインスタンスメソッドが追加されます。

- articles()：全ての article リソース配列

また、全てのリソースに、以下のメソッドが追加されます：

- is_article?：article かどうか
- to_article!：当該リソースを article 属性を持たせる


### ディレクトリサマリー / DirectorySummary
activate の際、テンプレートを指定するとディレクトリサマリー生成機能が稼働します。

```ruby
activate :akcms do |conf|
  conf.directory_summary_template = "templates/directory_summary.html"
end
```

これにより、例えば foo/bar/baz.html というリソースがあった場合、

- foo/bar/index.html
- foo/index.html
- index.html

が（存在しなければ）テンプレートに従いプロキシリソースが生成されます。
その際、ローカル変数として、

- directory:  当該ディレクトリの情報を保持するname, path メソッドを持つオブジェクト
- articles[]：当該ディレクトリ下にある article のリソース配列

```erb
% cat templates/directory_summary.html.erb
<h1>Directory: <%= directory.name %></h1>
<ul>
<% articles.each do |article| %>
  <li><%= link_to(article.title, article) %>
<% end %>
</ul>
```

などとします。

## 利用できるヘルパー、メソッド

### helper

- pagination?：ペジネーションが利用できれば真
- copyright：コピーライト表記

### Middleman::Sitemap::Store

- articles()：記事コレクション
- index_resource(path)：
- tags()
- archives()

### Middleman::Sitemap::Resource

- is_article?()
- to_article!()
- directory()
  - name, path
  - children_indices, index

- paginator{}
  - page_number
  - num_pages
  - articles

- metadata{:locals}{}
  - series{}
    - number

### Article

記事(Article)として認識されたリソース（後述）は、以下のメソッドを持ちます。

- title：記事タイトル
- date：日付。date: フロントマターあるいは更新日時
- summary：サマリー表示
- published?：出力するか。published: false でなければ真
- prev_article：次の記事
- next_article：前の記事
- body：記事本文（レイアウト不使用）
- tags:



## 機能と実装
### Controller
Middleman::Akcms::Controllerクラス。

ヘルパ関数 akcms でtemplate や layout からコントローラにアクセスできます。
このコントローラー経由で、下記の機能オブジェクトにアクセスします。

### Manipulator
拡張機能のキモ：resource を manipulate する機能集団。現在以下の5つあります：

- ArticleManipulator
- CategoryManipulator
- TagManipulator
- ArchiveManipulator
- PaginatorManipulator

#### ArticleManipulator
記事群を生成するクラス。
resource から ext == ".html"なリソースに
Middleman::Akcms::ArticleResource module を extend し、
date, title, category などのメソッドを追加します。

これらの記事群は archives[] に集められ、akcms.arcives でアクセスできます。
新しい記事を取得したければ、

```ruby
akcms.articles.first(10).each do |article|
  link_to(article.title, article)
end
```

などとします。

#### CategoryManipulator
本クラスのインスタンスオブジェクトの categories{}に、
category_template.html.erb に従って生成されたプロキシリソースのハッシュが入ります。
各記事のmetadata[:locals] にでname, display\_name, articlesが取得できます。

nameはgame/wot のようにフルパスですが、display\_nameは wotのみ、あるいはsource/game/wot/category\_name.txtがあれば中身を使います。

```ruby
akcms.categories.each do |category, res|
  link_to(category, res)
end
```

あるいは、標準の parent, children メソッドを使って、再帰ツリーを表示せることもできます。
詳しくは
[middleman\-akcms/categories\.html\.erb at master · atarukodaka/middleman\-akcms](https://github.com/atarukodaka/middleman-akcms/blob/master/template/source/categories.html.erb) および
[middleman\-akcms/\_category\_list\.erb](https://github.com/atarukodaka/middleman-akcms/blob/master/template/source/partials/_category_list.erb)
参照。

指定カテゴリに属するの記事群は、category_resource.locals[:articles] に入ってるので、
プロキシテンプレートでは、articles でとれます。


#### TagManipulator
タグ。同様に akcms.tags{} にプロキシリソースハッシュが入ります。

```ruby
akcms.tags.each do |tag, res|
  link_to(tag, res)
end
```

#### ArchiveManipulator
月別アーカイブ。

月別アーカイブはakcms.archives{} で取得できます。リソースのハッシュです。中身はproxy resourceで、localsでdate, articlesが取れます。

#### PaginatorManipulator

ペジネーションは、mm4についてるper\_pageを使ってます。frontmatterにpagination: trueをつけると、ペジネーションが有効になります。
proxy template には、page\_articlesとして表示分記事が渡り、paginator変数に、page\_number num_pages next\_page prev\_pageが使えます。

簡単なページャーは、テンプレートに以下のように記述します：

```ruby
  <nav>
    <ul class="pager">
      <% if paginator.prev_page %>
      <li class="previous"><%= link_to("prev", paginator.prev_page) if paginator.prev_page %></li>
      <% end %>
      <% if paginator.next_page %>
      <li class="next"><%= link_to("next", paginator.next_page) if paginator.next_page %></li>
      <% end %>
    </ul>
    <div class="text-center">
      <%= paginator.page_number %> / <%= paginator.num_pages %>
    </div>
  </nav>
```

また、fromtmatter で

```yaml
title: ぺじネーションテスト
pagination:
  per_page: 5
```

と記事毎にパラメータを指定することができます。

## Tips
### .emacs
.emacs や .emacs.d/init.el に

```elisp
(require 'autoinsert)
(add-hook 'find-file-hooks 'auto-insert)
(setq auto-insert-query nil)
(setq auto-insert-alist 
      '(("\\.html\\.md$" . frontmatter-skeleton)
	  ("\\.html\\.md\\.erb$" . frontmatter-skeleton)))

;; middleman-blog: article-front matter
(defun insert-article-frontmatter ()
  (interactive)
  (insert (concat "---\ntitle: \ndate: " (format-time-string "%Y-%m-%d") "\n\n---\n")))
(define-key global-map "\C-ca" 'insert-article-frontmatter)
```

とやっておくと便利です。

#### data/config.yml
著者名や著者・サイト情報をYAMLで記述します。テンプレートで data.config.author などと取れます。
