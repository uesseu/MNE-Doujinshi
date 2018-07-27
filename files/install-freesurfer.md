
# freesurferのインストール
freesurferをインストールしましょう。
下記のurlからダウンロードできます。windows版？そんなものはない。

```
https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall
```

で、ダウンロードしたファイルを
```{frame=single}
tar -C /usr/local -xzvf hoge.tar.gz
```
Macならインストーラーもあります！
ね、簡単でしょう？でも、まだ終わっていません。このままでは動きません。
設定をしないといけないのです。設定ファイルはホームディレクトリに
ある隠しファイルです。

テキストエディタは何でも良いですが、とにかく編集しましょう。
「隠しファイルなにそれ」な人は、unix系の勉強をしましょう！
僕はとても優しいので教えますが、「.」で始まるファイル名は
隠しファイルになります。

freesurferのダウンロードページに、Setup & Configurationという所があります。
四角で囲んである部分をコピーして、隠しファイルの.bash_profileに追記しましょう。

貴方が使っているシェルに応じてどれをコピペするかが決まるのですが、
大抵はbashと思います。

で、コピペし終わったら、保存して閉じるんですが、MRIの解析結果の
保存先(subject_dir)を決めてあげたい場合は下記のようにします。
```{frame=single}
export SUBJECTS_DIR=hoge
```
これは決めてあげたほうが良いです。何故なら、標準のsubject_dirは
読み書きに管理者権限が必要だったりするからです。

最後にライセンスキーを入れましょう。
freesurferの公式サイトに登録して、ライセンスキーをメールでもらい、
freesurferのディレクトリに突っ込みます。

面倒いので、あとはfreesurferのサイトを読んで下さい。

