
\newpage
## mricron/crogl(MRIを使う場合)

MRIの形式って色々あります。例えば誰かの脳の画像を手に入れて、
それを解析できなければ悲しいですね？
そこで、変換ソフトが必要になります。
ここではmricronとmricroglを紹介しますが、
僕は後者のほうが新しいしトラブルも少ないのでいいと思います。
実は他にMRIconverterとか言うのもあるらしいですが、
僕はMRIの専門ではないのでよく分かりません…。

mricronはUBUNTUなら
```{frame=single}
sudo apt install mricron
```
MACならhttp://www.mccauslandcenter.sc.edu/crnl/mricron/から
インストーラーをダウンロードします。このmricronファミリーの中にあるdcm2niiというソフトが
MRIの形式の変換に大変有用です。

さて、新しいmricroglですが、ここからダウンロード出来ます。
[http://www.mccauslandcenter.sc.edu/mricrogl/](http://www.mccauslandcenter.sc.edu/mricrogl/)
これはたまにmricronでは変換できないものを変換することが出来ます。

ちなみに、Debian系Linuxは神なので、Ubuntuなら下記で大丈夫です。

```{frame=single}
sudo apt install dcm2niix
```

以上でfreesurfer/MNE/pythonのインストールは終了しました。
これでゴリゴリ計算していくことができます。


### MRIのファイルの変換

mricronもmricroglもmriの画像の閲覧が出来るソフトです。
ちゃんと変換の前に内容を見ましょう。
MRIって結構撮り損ないがあるものです。
この中にdcm2niiというソフトがあるはずなので、そのソフトを起動します。
mricronならdcm2niigui、mricroglならメニューからimport辺りを探して下さい。

![dcm2niiの画面](img/nifti.png){width=14cm}


![mricronによる3DMRI画像の閲覧](img/mricron.png){width=14cm}

例えば手元にあるMRIの形式がdicomならば、方言を吸収するためにNIFTI形式に直した方が
僕の環境では安定していました。dcm2niiguiの画面にdicomのフォルダをドラッグしてください。
ファイルが出力されるはずです。

さて、出力されたファイルですが、3つあるはずです

- hogehoge:単純にniftiに変換された画像
- ohogehoge:水平断で切り直された画像
- cohogehoge:脳以外の不要な場所を切り取った画像

となります。どれを使っても構わないと思います。
でも、大事なことがあります。**使うソフトや変換の方法は合わせて下さい**
なにやら、それぞれが微妙に違うのだそうです。MRIに詳しい人が言ってた。
