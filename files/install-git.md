
# バージョン管理git

バージョン管理を知っているでしょうか？
貴方はスクリプトを書くことになるのですが、ちょっとしたミスでスクリプトは動かなくなります。
そんなリスクを軽減するために、貴方はスクリプトのコピーを取ります。
コピーを取り続けるうちに、貴方のコンピュータはスクリプトで埋め尽くされ、収集つかなくなります。
さらに、他の人がスクリプトを手直しする時、引き継ぎとかも大変です。
だから、貴方はgitを使ってください。
gitを知らない人は、とりあえずgithub desktopとかsource treeをダウンロードして
体でそれを知ってください。詳しくはgitでググってください。
こことか参考になります。
http://www.backlog.jp/git-guide/

## gitサーバー
git単体でもいけるのですが、折角だからgitのサーバーを導入してみましょう。
一番いいのはgithubのプライベートリポジトリを使うことなんですが有料です。
他にもbitbucketだとかgitlabとか色々あるのですが…僕自身は研究室のローカルなサーバーで
実現したかったんです~~趣味もある~~
なので、gitbucketを採用しました。gitbucketはgithubのクローンを目指して開発されたものです。

### gitbucket導入
gitbucketをググってgitbucket.warをダウンロードしてください。
で、javaというか、jdkをインストールします。めんどいんで詳しくはググってください。
http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

このまま
```{frame=single}
java -jar gitbucket.war
```
でも動くのですが、安定性に欠けるらしいので僕はPostgreSqlを導入します。

とりあえず、いくつかunixユーザーを作りましょう…。
そんで、データベース上に自分とgitbucketを登録します。

```{frame=single}
useradd postgres
passwd postgres
su postgres
createuser -d hoge
createdb hoge
createdb gitbucket
exit
```

上記で一応なんとかなると思うのですが、念のため確認を…
postgresqlにログインして下記を叩けばちゃんとデータベースが出来たかを確認できます。

```{frame=single}
\du
```

.gitbucket/database.confを下記のように書き直します。
```{frame=single}
db {
  url = "jdbc:postgresql://localhost/gitbucket"
  user = "test"
  password = "test"
}
```
で、
```{frame=single}
java -jar gitbucket.war
```

これでip+:8080にアクセスすればgitbucket動いてます。
(もちろん、これだけではセキュリティ面等、不十分です。
  セキュリティ詰める自信がないならローカルだけで使いましょう。)

## jupyterで作ったスクリプトのバージョン管理(小技)
jupyterを僕は使いますが、jupyterのファイルはgitしにくいです。
でも、何とかなります。

方法は2つありますが、僕は方法2が楽でいいと思っています。

### 方法1
```{frame=single}
jupyter notebook --generate-config
```
このコマンドでjupyterのコンフィグファイルが作成されます。
場所は/home/user/.jupyterです。
その上で、下記URLに記載されている通りに書き加えます。
http://jupyter-notebook.readthedocs.io/en/latest/extending/savehooks.html
すると、jupyterで編集したファイルがpythonのスクリプトとしても保存されます。
あとはgit[^git]などで管理すればいいです。
ただし、この方法は計算結果がファイル内に残りません。
しかも散らかります。
どちらかというと素直にpyファイルにして
ダウンロードしてgitを使うほうが良いかもしれません。

[^toukei]:同様に、matlabやC等と連携をすることが簡単なのがjupyterの強みの一つと思います。
[^git]:プログラミング用バージョン管理ソフト。敷居は高いが多機能。

### 方法2(あまりおすすめしない)
gitを使いますが、git側の設定だけでもどうにかなります。
まず、jqをインストールします。
.gitattibuteに書きを書き加えます。
無ければ作ってください。
```{frame=single}
*.ipynb diff=ipynb
```
そして、下記を.git/configに
```{frame=single}
[diff "ipynb"]
textconv=jq -r .cells[] |{source,cell_type}
prompt = false
```
下記を.gitignoreに
```{frame=single}
.ipynb_checkpoints/
```
これでjupyter notebookのファイルをgitで管理しやすくなります。
