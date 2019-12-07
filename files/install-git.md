
# バージョン管理git

バージョン管理を知っているでしょうか？
貴方はスクリプトを書くことになるのですが、ちょっとしたミスでスクリプトは動かなくなります。
そんなリスクを軽減するために、貴方はスクリプトのコピーを取ります。
コピーを取り続けるうちに、貴方のコンピュータはスクリプトで埋め尽くされ、収集つかなくなります。
さらに、他の人がスクリプトを手直しする時、引き継ぎとかも大変です。
そんな貴方はgitを使うと幸せに成れます。
gitを知らない人は、とりあえずgithub desktopとかsource treeをダウンロードして
体でそれを知ってください。詳しくはgitでググってください。
こことか参考になります。
[git-guide http://www.backlog.jp/git-guide/](http://www.backlog.jp/git-guide/)

## gitサーバー
git単体でもいけるのですが、gitサーバーというのもあります。
最近Microsoftが気前よくgithubのプライベートリポジトリを無料化したので、
それを使うのもいいでしょうね。
ただ、自分の研究用スクリプトをアップしたくないなら自前で鯖立てするのもいいし、
そもそも鯖立てなくても十分便利です。
一つ言えるのは、これ間違ってpublicとして個人情報を
githubに上げちゃったりすると捕まりますので、これだけは注意しましょう。


## jupyterで作ったスクリプトのバージョン管理(小技)
jupyterのファイルはgitしにくい上にすっごい散らかるので
きちんとコーディングする場合はオススメしません。
あくまでサブとして使う事をおすすめします。
重いしね…


### 方法1(超面倒くさい)

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
しかも散らかりますし、面倒くさいです。

[^toukei]:同様に、matlabやC等と連携をすることが簡単なのがjupyterの強みの一つと思います。
[^git]:プログラミング用バージョン管理ソフト。敷居は高いが多機能で超速。GUIクライアントも豊富。

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
色んな理由でおすすめはしませんけどね…
