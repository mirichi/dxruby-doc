# DXRuby 1.4.2 リファレンスマニュアル
## はじめに
DXRubyは、オブジェクト指向スクリプト言語RubyからDirectXを扱う為の拡張ライブラリです。
Rubyを使ってWindows用2Dアクションゲームなどを作ることができます。
このヘルプファイルはDXRubyのリファレンスマニュアルとなっております。
更なる情報をお求めの方はosdn.jpのプロジェクトWikiを参照してください。

* プロジェクトWiki  
  <http://dxruby.osdn.jp/cgi-bin/hiki.cgi>

また、プロジェクトWebにはOggVorbis再生ライブラリVoxをRubyから使うラッパvox.rb、
高機能オーディオライブラリを扱うラッパbass.rbも置いてあります。
Ayame/Rubyも追加しました。一長一短です。
未完成な部分もありますが、用途に合わせてお使いください。

* プロジェクトWeb
  <http://dxruby.osdn.jp/>


## マニュアル

* チュートリアル
  * [基本](tutorial/basic.md)
  * [応用/SoundEffect](tutorial/soundeffect.md)
  * [応用/Sprite](tutorial/sprite.md)
  * [応用/Shader](tutorial/shader.md)

* リファレンス
  * [APIリファレンス](api/index.md)
  * [キーコード定数](api/constant_keycode.md)
  * [色定数](api/constant_color.md)

* TIPS
  * [描画順序](tips/zindex.md)
  * [画像効果](tips/draw_effects.md)
  * [描画予約と破棄](tips/draw_reservation.md)
  * [文字コード](tips/encoding.md)
  * [リソースの解放](tips/release_resources.md)
  * ['ウィンドウを閉じる'のキャンセル](tips/cancel_window_closing.md)
  * [ocraによるexe化](tips/ocra.md)
  * [DXRubyExtension](tips/dxruby_extension.md)

* [更新履歴](CHANGELOG.md)


## DXRubyの特徴
DXRubyは以下のような特徴を持つライブラリです。

* RubyからDirectXを自然に扱える、Rubyと親和性の高い設計がされています。
* 初心者でも簡単に使えるよう、非常にシンプルなAPI構成になっています。
* 描画が速いので、遅いといわれるRubyでも普通にゲームが作れるぐらいの実行速度が出ます。
* Ruby2.0系/2.1系/2.2系に対応しています。自分でコンパイルできればそれ以降でも動くと思います。
* 配布しやすいよう、コンパクトな拡張ライブラリとなっています。

また、デメリットとしては以下のものがあります。

* DirectXを扱うのでWindows専用となります。
* 2Dゲーム専用です。
* 複雑なことを行うAPIは提供していません。

DXRubyが提供する機能は大まかに以下のものです。

* 画像の読み込み、描画
* 画像の編集
* キーボード、マウス、ゲームパッド(アナログ含)の入力
* MIDI、WAVファイルの読み込み、再生、ループ設定、フェードイン/アウト
* 文字表示
* FPS自動調整
* 高速な衝突判定
* HLSLを使ってシェーダプログラミングが可能

DXRubyを実行するのに必要な環境は以下のものです。

* Ruby本体
  * mswin32もしくはmingw32のRuby2.0系、Ruby2.1系、Ruby2.2系。
  * ActiveScriptRuby同梱版など、mswin32/mingw32以外でもそれ用にコンパイルされていれば動作します。
  * 64bit版では動作しません。
* OS
  * Windows2000以降
* DirectX
  * 9.0c以降


## インストール方法
**注意**
arton氏作のActiveScriptRubyは、コンパイラのバージョンが違うためSourceForge.jpからダウンロードしてインストールしても動作しません。
ActiveScriptRuby同梱のバージョンをお使いください。
その他のWindows用パッケージでmswin32/mingw32のRuby(RubyInstller for Windowsなど)を使っている方は
dxruby.soとdxrubyex.so、install.rbが同じディレクトリにある状態で、install.rbを実行してください。
install.rbを実行したら、sampleディレクトリ以下のファイルを実行してみて、きちんと動作すればインストール成功です。


## ライセンス
DXRuby本体は1.2.0安定版から、DXRubyExtensionは1.0.3からzlib/libpngライセンスを採用しています。

添付のサンプルスクリプト及びドキュメント内のスクリプトは全てパブリックドメインとします。著作者人格権は行使しません。
そのまま使うなり、改造するなり、著作権表示など一切いりませんのでご自由にどうぞ。

添付のさる画像はあみさんの著作物ですので、勝手な転載・複製などは固く禁じます。
他、画像を頂いた先は以下です。

* ルール画像
  * [吉里吉里のトランジションライブラリ](http://kikyou.info/tvp/)

* 背景画像
  * [きまぐれアフターさま](http://gakaiblog.at.webry.info/)

* 世界地図
  * [かんたんネットさま](http://kantan-net.main.jp/worldmap/)

* デフォルトアイコンは鳴海つかささま。

* それ以外の絵は水視アズマさま(GPL)。

zlib/libpngライセンスの詳細は原文(英語)を読んでいただくのが一番よいのですが、簡単に説明するとこんな感じです。

* 無制限に扱うことを無償で許可する。
* ソースを改変する場合に限り、著作権表示を含めること。
* 何が起きても責任は持ちません。

要するに、何かあっても知らないけど自由にどうぞ、ということです。
使うだけでは著作権表示がいらないぶん、1.0.9以前で採用していたMITライセンスよりももうちょっとゆるくなっています。
また、著作権表示は以下のものです。
これそのものがzlib/libpngライセンス自体の原文で、上記のようなことが書いてあります。

```
The zlib/libpng License
Copyright (c) <2012> <DXRubyDevelopers>

This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
```

