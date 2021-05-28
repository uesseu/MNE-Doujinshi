
\newpage
# freesurferのインストール
freesurferをインストールしましょう。
下記のurlからダウンロードできます。windows版？そんなものはない。[^wsl]

[^wsl]: もしどうしても君がWindowsを使わねばならぬならWSL(Windows Subsystem for Linux)を使えばいいかもしれない。

```
https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall
```

で、ダウンロードしたファイルを

```{frame=single}
tar -C /usr/local -xzvf hoge.tar.gz
```

Macならインストーラーもあります！
ね、簡単でしょう？でも、まだ終わっていません。このままでは動きません。

必要なソフトをいくつか入れる必要があります。
Ubuntuなら

```{frame=single}
sudo apt install tcsh csh
```

Macなら
```{frame=single}
sudo apt install tcsh csh
```

設定をしないといけないのです。設定ファイルはホームディレクトリにある隠しファイルです。

テキストエディタは何でも良いですが、とにかく編集しましょう。
「隠しファイルなにそれ」な人は、unix系の勉強をしましょう！
僕はとても優しいので教えますが、「.」で始まるファイル名は隠しファイルになります。

freesurferのダウンロードページに、Setup & Configurationという所があります。
四角で囲んである部分をコピーして、隠しファイルの.bash_profileに追記しましょう。
場合によっては.bashrcのこともあるかも知れませんね。

貴方が使っているシェルに応じてどれをコピペするかが決まるのですが、大抵はbashと思います。

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

あと、忌々しい事に、Ubuntu18.04以降ではfreesurferの一部である
freeviewを起動するときに「libpng12がない」と怒られます。
Ubuntu18のリポジトリにはないので、仕方ないので古いリポジトリからくすねます。
https://packages.ubuntu.com/xenial/amd64/libpng12-0/download
本当はいけないんだけどね…

```{frame=single}
wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
```

さらに、libjpeg62というのも必要になります。

```{frame=single}
sudo apt install libjpeg62
```

面倒いので、あとはfreesurferのサイトを読んで下さい。

