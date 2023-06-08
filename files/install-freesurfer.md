
\newpage
## freesurferのインストール
freesurferをインストールしましょう。
下記のurlからダウンロードできます。
[https://surfer.nmr.mgh.harvard.edu/fswiki/rel7downloads](https://surfer.nmr.mgh.harvard.edu/fswiki/rel7downloads)
Ubuntu、CentOS、MACOSがありますね！
Windows版？ハッw そんなものはない。
もしどうしても君がWindowsを使わねばならぬなら
WSL(Windows Subsystem for Linux)を使えばいいかもしれないです。
というか、僕の手元では動いたので動くと思います。
Macなら下記のソフトも必要です。Xwindowシステムですね。
[https://www.xquartz.org/](https://www.xquartz.org/)
素でXwindowシステムが動くのがLinuxディストリビューションなので、
ここが僕がLinuxディストリビューションを気に入っている理由です。

Ubuntuなら
```{frame=single}
sudo dpkg -i hoge
```
でパッケージをインストールできます。

MacならGUIのインストーラーあります！
ね、簡単でしょう？でも、まだ終わっていません。このままでは動きません。

もしかすると、追加で下記が必要かも分かりません。Ubuntuなら

```{frame=single}
sudo apt install tcsh csh
```

Macなら
```{frame=single}
sudo brew install tcsh csh
```

あとは、設定をしないといけないのです。
設定ファイルはホームディレクトリにある隠しファイルです。

テキストエディタは何でも良いですが、とにかく編集しましょう。
「隠しファイルなにそれ」な人は、unix系の勉強をしましょう！
僕はとても優しいので教えますが、「.」で始まるファイル名は隠しファイルになります。

freesurferのダウンロードページに、Setup & Configurationという所があります。
四角で囲んである部分をコピーして、隠しファイルの.bash_profileに追記しましょう。
場合によっては.bashrcのこともあるかも知れませんね。

貴方が使っているシェルに応じてどれをどんな風にコピペするかが決まるのですが
大抵はbashかzshと思います。
linuxなら
[https://surfer.nmr.mgh.harvard.edu/fswiki//FS7_linux](https://surfer.nmr.mgh.harvard.edu/fswiki//FS7_linux)
Macなら
[https://surfer.nmr.mgh.harvard.edu/fswiki//FS7_mac](https://surfer.nmr.mgh.harvard.edu/fswiki//FS7_mac)
を見て下さい。

要するにこんなふうなのを設定ファイルに書き加えるんですね。
```{frame=single}
export FREESURFER_HOME=$HOME/hoge
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

1行目を見て下さい。
これはFreesurferがホームディレクトリの'hoge'にインストール
されている場合ですね。

で、コピペし終わったら、保存して閉じるんですが、MRIの解析結果の
保存先(subject_dir)を決めてあげたい場合は下記のようにします。

```{frame=single}
export SUBJECTS_DIR=fuga
```

これは決めてあげたほうが良いです。何故なら、標準のsubject_dirは
読み書きに管理者権限が必要だったりするからです。
あと、毎回同じMRI研究をするわけでもないので、プロトコルが変わるなら
場所も変えてあげたいですよね！

最後にライセンスキーを入れましょう。
freesurferの公式サイトに登録して、ライセンスキーをメールでもらい、
freesurferのディレクトリに突っ込みます。

面倒いので、あとはfreesurferのサイトを読んで下さい。

