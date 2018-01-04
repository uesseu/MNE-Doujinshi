# mricronのインストールと変換(MRIを使う場合)

mricronが必要になることもあるので、入れましょう。UBUNTUなら
```{frame=single}
sudo apt install mricron
```
MACならhttp://www.mccauslandcenter.sc.edu/crnl/mricron/から
インストーラーをダウンロードします。このmricronファミリーの中にあるdcm2niiというソフトが
MRIの形式の変換に大変有用です。

以上でfreesurfer/MNE/pythonのインストールは終了しました。
これでjupyter経由でゴリゴリ計算していくことができます。

## mricronによるMRIのファイルの変換

mricronはmriの画像の閲覧が出来るソフトですが、
この中にdcm2niiguiというソフトがあるはずなので、そのソフトを起動します。

![dcm2niiの画面](img/nifti.png){width=14cm}

ちなみに、mricron自体はmri閲覧ソフトで、これもこれで有用です。

![mricronによる3DMRI画像の閲覧](img/mricron.png){width=14cm}

例えば手元にあるMRIの形式がdicomならば、方言を吸収するためにNIFTI形式に直した方が
僕の環境では安定していました。dcm2niiguiの画面にdicomのフォルダをドラッグしてください。
ファイルが出力されるはずです。

さて、出力されたファイルですが、3つあるはずです
- hogehoge:単純にniftiに変換された画像
- ohogehoge:水平断で切り直された画像
- cohogehoge:脳以外の不要な場所を切り取った画像

となります。どれを使っても構わないと思います。

\newpage
