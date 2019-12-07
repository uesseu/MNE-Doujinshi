
## OSの準備
OSはlinuxかMACが普通と思います、windowsではどうなのでしょう？
MNEpythonは動きます。
Unix系コマンドラインツールは動きません。freesurferは辛いです。
WSL2というlinux互換機能の実力を僕は知らないのでなんとも…
というわけで、僕は新しめのdebian系linuxディストリビューションである
UBUNTU[^ubuntu]またはMACを使います。

[^ubuntu]:UBUNTUはCanonical社によって開発されているオープンソースのlinuxディストリビューションであり、人気があります。debianというディストリビューションをベースに作られています。

linuxでも新しめのメジャーなlinuxディストリビューションを勧める理由は
CUDA等の技術に対応していたり、ユーザーが難しいことを考えなくて良いことが多いからです。
debian系を使う理由はパッケージ管理ソフトのaptが優秀でユーザーが多いことです。
MACの場合はaptの代わりに [homebrew https://brew.sh/index_ja.html](https://brew.sh/index_ja.html) を用いることになります。
以下、UBUNTU16.04LTS以上かmacos10.12を想定して書いていきます。
UBUNTU16.04LTSは下記サイトから無料でダウンロードできます。

[Ubuntu https://www.ubuntulinux.jp/ubuntu](https://www.ubuntulinux.jp/ubuntu)

僕自身は少しでも速く処理して欲しいので、誤差範囲かもですがlinuxでは軽量デスクトップ環境に
変えています…ここは任意です。
