
## OSの準備
OSはlinuxかMACが普通と思います、windowsではどうなのでしょう？[^win]
よく分かりませんが、MNEpythonは動きます。
Unix系コマンドラインツールは動きません。freesurferは辛いです。
僕は新しめのdebian系linuxであるUBUNTU[^ubuntu]またはMACを使います。

[^win]:anacondaはosの垣根を越えているので、大丈夫なのでしょうけれど僕は試していません。

[^ubuntu]:UBUNTUはCanonical社によって開発されているオープンソースのlinuxディストリビューションであり、人気があります。debianというディストリビューションをベースに作られています。

linuxでも新しめのメジャーなlinuxディストリビューションを勧める理由は
CUDA等の技術に対応していたり、ユーザーが難しいことを考えなくて良いことが多いからです。
debian系を使う理由はパッケージ管理ソフトのaptが優秀でユーザーが多いことです。
MACの場合はaptの代わりにhomebrew(https://brew.sh/index_ja.html)を用いることになります。
以下、UBUNTU16.04LTSかmacos10.12を想定して書いていきます。
UBUNTU16.04LTSは下記サイトから無料でダウンロードできます。

https://www.ubuntulinux.jp/ubuntu

僕自身は少しでも速く処理して欲しいので、誤差範囲かもですがlinuxでは軽量デスクトップ環境に
変えています…ここは任意です。MACを使う場合はhomebrewというパッケージマネージャを
インストールすると色々楽になることがあります。
https://brew.sh/index_ja.html
