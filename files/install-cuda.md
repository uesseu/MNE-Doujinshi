
## CUDA
CUDAをご存知でしょうか？
GPUを科学計算に用いる方法の1つで、Nvidia社が開発しているものです。
GPGPUと呼ばれる技術の一種ですね。
これはMNEpythonでも使うことが出来るので、やってみましょう。
つっても、今の所フィルター関連だけなんですけどね…
しかもあまり速くない上に、Ubuntuの新しいやつでドライバが動かないとか
そういうツラミが出てきていてあまりおすすめではないです。
あと、ついにMacでNvidiaがサポートされなくなったりしています。

これのインストールも詰まるとそれなりに面倒です。
まずは、Nvidiaのサイトからインストーラーをダウンロードします。

[Nvidia https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)

このサイトには色々なOSに対応したCUDAが置いてあります。
僕はubuntuならdeb(network)をお勧めします。面倒臭さが低いです。
インストーラーをダウンロードしてダブルクリックするだけではダメで、
ダウンロードのリンクの下にある説明文を刮目して読みましょう。
こんな感じに書いてあります(バージョンによって違います)

```{frame=single}
sudo dpkg -i cuda-repo-ubuntu1604_9.1.85-1_amd64.deb
sudo apt-key adv --fetch-keys http://hogehoge.pub
sudo apt-get update
sudo apt-get install cuda
```

こんな感じのがあるはずなので、実行して下さい。
もちろん、バージョンとかは読み替えるべし。
そして、これが大事なのですが、bashrcにパスを通す必要があります。
これはCUDAのインストールガイドに書いてあります。
インストールガイドへのリンクは先程の説明の下に小さく書いてあります。
具体的には下記のような感じです。

```{frame=single}
export PATH=/usr/local/cuda-9.1/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-9.1/lib64\
      ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```
これでCUDAへのリンクが貼れたはずです。
bashを再起動しましょう。
MNEpythonのCUDAインストールのページに従ってコマンドを叩きます。
http://martinos.org/mne/stable/advanced_setup.html#advanced-setup

```{frame=single}
sudo apt-get install nvidia-cuda-dev nvidia-modprobe
git clone http://git.tiker.net/trees/pycuda.git
cd pycuda
./configure.py --cuda-enable-gl
git submodule update --init
make -j 4
python setup.py install
cd ..
git clone https://github.com/lebedov/scikit-cuda.git
cd scikit-cuda
python setup.py install
```
これでインストールできてたら成功です。
pythonで

```{frame=single}
import mne
mne.cuda.init_cuda()
```
としたらEnabling CUDA with 1.55 GB available memory...
的なメッセージが出たりします。
そして、一番確実なのはMNEpythonに付属した
テストツールを回してみることです。

```{frame=single}
pytest test_filter.py
```
このテストツールはMNEpythonの中にあります。
場所的にはanacondaの中のlib/python3/site-package/mne/tests
的な場所にあると思うのですが、環境によって違うかもです。
このテストがエラーを吐かなければ…おめでとうございます！
貴方はMNEpythonをCUDAで回すことが出来ます！
つっても、今の所フィルター関連だけなんですけどね…
