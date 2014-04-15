# チュートリアル

## 基本の形
最低限のスクリプトは以下のようになります。

```ruby
require 'dxruby'

Window.loop do
  # ここにゲームの処理を書く
end
```

dxrubyをrequireして、Window.loopメソッドの中にゲームの処理を書きます。
Window.loopメソッドは、何も設定しなければ、実行時に640*480のウィンドウを作成し、タイトルを"DXRuby Application"とします。
また、doとendの中は1秒間に60回のペースで実行されるよう、自動的に調整されます(60fps)。
１ループごとに入力情報の更新と、画面のクリア・描画がされますので、ハードウェア周りについて何も意識する必要はありません。

このスクリプトを実行すると、以下のようなウィンドウが表示されます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen01.jpg)

このウィンドウを閉じると、Window.loopメソッドは自動的に終了します。
また、breakなどでWindow.loopを抜けると、自動的にウィンドウが閉じられます。



## 画像の読み込みと描画
画像の読み込みはImageクラスで行い、描画はWindowモジュールのdrawメソッドを使用します。

```ruby
require 'dxruby'

image = Image.load('data.png')  # data.pngを読み込む

Window.loop do
  Window.draw(100, 100, image)  # data.pngを描画する
end
```

Imageクラスのloadメソッドは、指定したファイル名の画像を読み込んで、Imageオブジェクトを返します。
Windowモジュールのdrawメソッドは、指定の位置にImageオブジェクトを描画します。
この例では、x座標100、y座標100の位置にdata.pngを描画しています。
座標は、画面の左上の点が(0, 0)となり、640*480の場合だと右上が(639, 0)、左下が(0, 479)、右下が(639, 479)となります。

上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、以下のようなウィンドウが表示されます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen02.jpg)



## 画像の分割読み込み
ゲームを作る場合、複数の画像を１つのファイルにまとめることがよくあります。
そういったファイルを読み込んで、複数のImageオブジェクトを生成するには、Imageクラスのload_tilesメソッドを使います。

```ruby
require 'dxruby'

image = Image.load_tiles('data.png', 2, 2)  # data.pngを読み込んで、横２つ、縦２つに分割する

Window.loop do
  Window.draw(100, 100, image[0])  # data.pngの左上を描画する
  Window.draw(150, 100, image[1])  # data.pngの右上を描画する
  Window.draw(100, 150, image[2])  # data.pngの左下を描画する
  Window.draw(150, 150, image[3])  # data.pngの右下を描画する
end
```

Imageクラスのload_tilesメソッドは、指定した画像ファイルを縦、横に分割し、Imageオブジェクトの配列として返します。
配列に格納される順番は、左上から右へ、上から下の順番となります。
上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、以下のようなウィンドウが表示されます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen03.jpg)



## 画像の部分切り出し
load_tilesメソッドは、全ての画像が同じサイズであることが前提となっています。
１つのファイルに違うサイズの画像が混在している場合は、sliceメソッドを使って１部分だけ切り出します。

```ruby
require 'dxruby'

baseimage = Image.load('data.png')  # data.pngを読み込む
image = baseimage.slice(0, 0, 20, 20)  # data.pngの(0, 0)から20*20pixel分だけ画像を切り出す

Window.loop do
  Window.draw(100, 100, image)  # data.pngの左上20pixel正方形を描画する
end
```

Imageクラスのsliceメソッドは、指定したImageオブジェクトの１部分を切り出し、新たなImageオブジェクトを生成して返します。
上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、以下のようなウィンドウが表示されます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen04.jpg)



## カーソルキーの入力
入力の取得はInputモジュールを使います。
キャラの移動に使うカーソルキーやゲームパッドの十字キーの入力には、Input.x、Input.yを使います。

```ruby
require 'dxruby'

image = Image.load('data.png')  # data.pngを読み込む
x = 0
y = 0

Window.loop do
  x = x + Input.x  # x座標の更新
  y = y + Input.y  # y座標の更新

  Window.draw(x, y, image)  # data.pngを描画する
end
```

Input.x、Input.yメソッドは、カーソルキーもしくは、１つ目のゲームパッドの十字キーの入力を、それぞれx座標の増分、y座標の増分で返します。
左・上を押した場合は-1、右・下は1、押していなければ0です。左右同時押し、上下同時押しの場合も0になります。

上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると以下のようなウィンドウが表示され、
カーソルキーか、１つ目のゲームパッドの十字キーで移動させることができます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen05.jpg)



## パッドの入力
ゲームパッドの入力もInputモジュールを使います。
取得可能なボタンは十字キーと、ボタン０～１５までです。
DXRubyでは１つ目のゲームパッドとキーボードが連動していて、パッドの入力をチェックすると、
連動しているキーが押されていても同様に押されていると判定できます。
デフォルトで連動しているボタンとキーは以下のものです。
* 十字キーとカーソルキー
* ZXCと、ボタン０～２

パッドの入力を取得するには、Input.pad_down?／Input.pad_push?メソッドを使います。

```ruby
require 'dxruby'

image = Image.load('data.png')  # data.pngを読み込む
x = 0
y = 0
dx = 0
dy = 0

Window.loop do
  dx = Input.x  # x座標の移動量
  dy = Input.y  # y座標の移動量

  if Input.pad_down?(P_BUTTON0) then  # Zキーかパッドのボタン０を押しているか判定
    dx = dx * 2
    dy = dy * 2
  end

  x = x + dx
  y = y + dy

  Window.draw(x, y, image)  # data.pngを描画する
end
```

pad_down?メソッドは、ボタンが押されているかどうかを判定し、true/falseを返します。
pad_push?メソッドは押された瞬間のみtrueになるメソッドです。
上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、以下のようなウィンドウが表示されます。
カーソルキーか１つ目のゲームパッドの十字キーで移動させることができ、Zキーかパッドのボタン０を押している間、倍速で移動します。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen05.jpg)



## マウスの入力
マウスカーソルの入力はmouse_pos_x／mouse_pos_y、ボタンの状態はmouse_push?／mouse_down?で取得できます。

```ruby
require 'dxruby'

image = Image.load('data.png')  # data.pngを読み込む

Window.loop do
  x = Input.mouse_pos_x  # マウスカーソルのx座標
  y = Input.mouse_pos_y  # マウスカーソルのy座標

  Window.draw(x, y, image)  # data.pngを描画する
end
```

mouse_pos_x／mouse_pos_yメソッドで取得できる値は画面内の座標と一致します。
マウスのボタン入力は、パッドの入力と同じような感じでメソッド名と引数が違い、引数はM_LBUTTONが左ボタン、M_RBUTTONが右ボタンとなります。
上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、以下のようなウィンドウが表示されます。
マウスカーソルの位置に画像が移動します。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen02.jpg)



## キーボードの入力
キーボードの入力を取得するには、Input.key_down?／Input.key_push?メソッドを使います。
パッドの入力と同様に、関連付けられているキーはパッドが押されていてもtrueが返ります。

```ruby
require 'dxruby'

image = Image.load('data.png')  # data.pngを読み込む

Window.loop do
  Window.draw(100, 100, image)  # data.pngを描画する
  if Input.key_push?(K_ESCAPE) then  # Escキーで終了
    break
  end
end
```

判定できるキーの種類とそれぞれの指定する引数は、リファレンスを参照してください。
上記スクリプトとDXRubyのsampleディレクトリ下のdata.pngを同じディレクトリに置いて実行すると、
以下のようなウィンドウが表示され、Escキーで終了することができます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen02.jpg)



## 文字の描画
文字を扱うにはFontクラスを使い、描画はWindowモジュールのdraw_fontメソッドを使用します。

```ruby
require 'dxruby'

font = Font.new(32)  # 第２引数を省略するとＭＳ Pゴシックになります

Window.loop do
  Window.draw_font(100, 100, "ふぉんと", font)  # "ふぉんと"を描画する
end
```

Fontクラスはフォントのサイズとフォント名を指定します。
たとえばＭＳ明朝を扱うなら、Font.newの第２引数に"ＭＳ 明朝"を渡します。マイクロソフトのフォント名はＭＳと明朝が全角、間のスペースは半角です。
Windowモジュールのdraw_fontメソッドは、指定の位置に指定の文字列を、Fontオブジェクトのサイズとフォントで描画します。
この例では、x座標100、y座標100の位置に、ＭＳゴシックの32pixelサイズで"ふぉんと"を描画しています。
上記スクリプトを実行すると、以下のようなウィンドウが表示されます。

![sample](http://dxruby.sourceforge.jp/DXRubyReference/Capture/gamen06.jpg)

**注** Ruby1.9.1以上を使う場合、先頭行にマジックコメントを挿入してください。
マジックコメントの例

```ruby
# coding: shift_jis
```



## 音を出す
BGMとしてMIDIを、効果音としてWAVファイルを扱うことができます。

```ruby
require 'dxruby'

sound = Sound.new("sound.wav")  # sound.wav読み込み
bgm = Sound.new("bgm.mid")  # bgm.mid読み込み

bgm.play

Window.loop do
  if Input.key_push?(K_Z) then  # Zキーで再生
    sound.play
  end
end
```

Soundクラスのnewメソッドでファイルを読み込み、playを呼び出します。
midiはループ再生され、wavは１回で再生が終了します。
DXRubyには音のファイルは同梱しておりませんので、上記のスクリプトは実行してもファイルが無くてエラーとなります。
自分で作るなりフリーの素材を使うなりして試してみてください。

