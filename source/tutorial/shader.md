# Shaderチュートリアル
## はじめに
ShaderクラスはDirectXのシェーダ言語HLSLを使ってシェーダプログラミングを可能にするクラスです。
従ってDXRubyの他のクラスとは違い、Rubyの知識のみで扱えるというものではありません。

HLSLの詳細は[マイクロソフトのサイト](http://msdn.microsoft.com/ja-jp/library/ee418149(v=vs.85).aspx)等を見て頂くとして、ここではDirectXとHLSLの基礎知識を解説してみます。

## HLSLとは

DirectX用のシェーダ言語です。High-Level Shader Languageらしいです。Cに似た文法、SIMD(1命令複数演算)に特化したデータ型/演算子仕様を持ち、GPUで高速動作するプログラムを書くことができます。

DXRubyではShader::Coreオブジェクトの生成時にHLSLコードをテキストで渡して、その時点でコンパイルし、GPU用バイナリを保持します。

DirectX9以降に対応したGPUであれば、GPUの違いはドライバが吸収してくれますし、極端に複雑なコードを書かなければGPUによる差異は感じられないでしょう。

## シェーダとは
GPUが持つ超並列簡易プロセッサと思えばだいたい正しいと思います。32bitの値を4つ同時に計算するなどができ、簡単なフロー制御も可能です。

GPUにはメーカーや製品ランクによって違いますが、数十から数百、ハイエンドでは2000オーバーのシェーダが搭載されており同時並列に動作します。

DirectXで使うシェーダにはいくつかの種類がありますが、DXRubyで使うのはピクセルシェーダのみです。ピクセルシェーダは画面の1ピクセルに出力する色を計算するためのシェーダで、例えば100*100ピクセルの画像を描画するとシェーダプログラムが10000回動きます。

1ピクセルにつき1回プログラムが実行される、この動作イメージが決定的に重要です。

## シェーダの動作とテクスチャ
画像を描画するとDirectXはまず描画対象のピクセルがどれかを計算します。

```ruby
image = Image,new(100,100,[255,255,255])
Window.draw(0,0,image)
```

というコードの場合、(0,0)から(99,99)の範囲に描画する、といった感じです。

ピクセルシェーダはその10000個のピクセルに対し、1回ずつ動作します。ピクセルシェーダへの入力は画像データであるテクスチャと、テクスチャ内のどの部分の色かを表すテクスチャ座標で、ピクセルシェーダはテクスチャから指定された位置の色を取得し、出力します。出力する場所はGPUが制御しますので、ピクセルシェーダ内で知る必要はなく、従ってそれを知ることはできません。ピクセルシェーダは画面のどの位置のピクセルを描画しているかは意識しないものなのです。

テクスチャ座標は(0.0, 0.0)～(1.0, 1.0)で表現されます。画像が2*2ピクセルでも100*100ピクセルでもこの表現方法は変わりません。

浮動小数点であるため、テクスチャのピクセル(テクセルといいます)に正確には対応していません。テクセルとテクセルの間の微妙な位置を指定した場合はデフォルトでは線形補間が行われますが、補間方法は変更することができます。


## 描画してみる
### 必要最低限のHLSLの例
テクスチャから単純に色を拾って出力するだけですので、普通に描画するのと結果は変わりません。

```
// (1) グローバル変数
  texture tex0;

// (2) サンプラ
  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

// (3) ピクセルシェーダのプログラム
  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;

    output = tex2D( Samp0, input );
    return output;
  }

// (4) technique定義
  technique Normal
  {
   pass P0 // パス
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
```

#### 説明
(1) グローバル変数
グローバル変数の定義で、textureは型、tex0が変数名です。DXRuby用のHLSLでは描画しようとする画像はtex0という名前で設定されますので、この指定は必須となります。

(2) サンプラ
テクスチャのサンプラ定義で、テクスチャから画像を取得(サンプル)するための指定です。ここではtex0の色をSamp0というサンプラで取得するということが書かれています。ほとんどの場合コピペで大丈夫です。

この中で例えば座標が0.0～1.0の範囲からはずれた(画像範囲外の色の取得の)場合にどの色を取得するか、とか、回転・スケーリング時の補間方法などを指定することができます。

(3) プログラム
シェーダプログラムの本体です。入力はfloat2のテクスチャ座標、出力はfloat4の色情報となっています。

floatとはCと同様の32bit浮動小数点値ですが、2とか4とかついているところがHLSLのポイントです。float2はfloatの値が2個セット、float4は4個セットになったベクトルのような型となっています。それぞれピリオドに続いてxyや、rgbaなどで要素へのアクセスが可能です。今回はまとめて使うのでそういったアクセスは行っていません。詳細はチュートリアル02以降で解説します。

このコードは、float4のoutputというローカル変数を定義し、そこにtex2Dという組み込み関数を使ってサンプラSamp0からinputが表す座標の色を取得して格納、outputを返すという動きをします。Cがわかる人ならなんとなく理解できるのではないでしょうか。

(4) technique定義
Rubyから呼び出す単位であるtechniqueを定義します。名称はNormalとなっていますが、これはShaderオブジェクト生成時に渡すものです。名称は省略可能です。 passはパスで、P0～(欠番は不可)で定義しておくことで順番に実行することができます。部分的に実行することはできません。通常はP0だけで問題ないと思います。1つだけの場合、名称は省略可能です。

実行するtechniqueはRuby側から指定できるので、techniqueを複数定義して使い分けることも可能です。

### RubyからHLSLを使う

上記HLSLテキストを渡してShader::Coreオブジェクトを作成し、それを使ってShaderオブジェクトを生成することで、Window/RenderTarget.draw_shaderやdraw_exで使うことができるようになります。

今回の例は通常のdrawと全く同じ結果になりますので、２つを並べて描画してみましょう。

HLSL部分は上と重複していますが、全文載せておきます。

```ruby
require 'dxruby'

hlsl = <<EOS
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;

    output = tex2D( Samp0, input );
    return output;
  }

  technique Normal
  {
   pass P0
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl)
shader = Shader.new(core, "Normal")

image = Image.new(100, 100, [255, 255, 255])

Window.loop do
  Window.draw(50, 50, image)
  Window.draw_shader(200, 50, image, shader)
end
```

これを動かすと、白い100*100ピクセルの四角が横に2個並ぶと思います。

### まとめ
これでHLSLとShaderクラスの扱い方の基本はOKでしょう。


## 色を変えて描画してみる
### 色情報にアクセスする
HLSLの色情報はfloat4という型で表され、Tex2D関数でテクスチャから取得した色情報はfloat4ですし、ピクセルシェーダの出力もfloat4になります。 float4は32bit浮動小数点であるfloatの値を4つセットにした型で、Cで言うところの構造体のようなものとなっています。要素の名前はr、g、b、aもしくはx、y、z、wです。たとえばfloat4型のoutputという変数があった場合、output.rで一つ目の値、つまり色情報であれば赤の色を取得することができますし、output.r=で赤の値だけ変更することができます。

HLSLでの色情報は0.0～1.0で表します。32bitカラーだとそれぞれ0～255までですが、HLSL上はそれが0.0～1.0の浮動小数点値となります。色の計算をするときはこのほうが楽なので、これはよい仕様だと思います。

### 強制的に赤にする
では描画する画像のrの値を強制的にMAXにするシェーダを作ってみましょう。コードは前回とほぼ同じなので、違いがあるピクセルシェーダ本体の部分のみを記載します。

```
float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;

  output = tex2D( Samp0, input );
  output.r = 1.0;
  return output;
}
```

outputに格納されたテクスチャの色情報にたいして、赤の情報を1.0に書き換えるようにしました。これだと例えば青一色の画像を描画しただけで紫一色になるはずです。

### 実行してみる
```ruby
require 'dxruby'

hlsl = <<EOS
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;

    output = tex2D( Samp0, input );
    output.r = 1.0;
    return output;
  }

  technique
  {
   pass
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl)
shader = Shader.new(core)

image = Image.new(100, 100, [0, 0, 255])

Window.loop do
  Window.draw(50, 50, image)
  Window.draw_shader(200, 50, image, shader)
end
```

techniqueの名前は省略するようにしました。これを実行すると、左のdrawで描画した画像は青ですが、右のシェーダを使った画像は紫になります。

### まとめ
このように、シェーダの使い方の一つは画像の色変更です。
この方法でRGBに好きな色を設定すれば透明な部分以外は固定の色にすることができますので、例えば攻撃が当たったキャラをフラッシュさせるようなことができますね。


## 動的に色を計算して描画してみる
### SIMD演算
HLSLのfloat4という型は4つのfloat型がセットになっており、それぞれr、g、b、aでアクセスできることは前回説明しました。前回はrだけ書き換えるという方法で値を変更しましたが、今回はテクスチャの値になんらかの計算をほどこして出力してみます。計算するには普通に計算式を書けばOKです。

```
output.r = output.r / 2;
```

とすれば赤情報が半分になります。このような形でそれぞれの色を計算すればよいわけですが、GPUはSIMD(Single Instruction Multiple Data)プロセッサですので、そのような計算をまとめて行うことができます。例えば、

```
output = output / 2;
```

とすると、outputのr、g、b、aがすべて半分になります。float4を4要素のベクトルと考えれば、ベクトルとスカラの計算ということになりますね。同様にベクトルとベクトルの計算もできます。

```
output = output + float4(0.1, 0.2, 0.3, 0.4);
```

このfloat4(...)という書き方はfloat4型のリテラル表記です。上記の計算をするとoutputのr、g、b、aがそれぞれ0.1、0.2、0.3、0.4だけ足されます。また、output.rgbなどという書き方もでき、この場合r、g、bを持つfloat3の値になります。同様の記法でrgbだけの書き換えも可能です。rgやgbなどといった自由な組み合わせの指定ができます。

```
output.rgb = output.rgb * float3(1.1, 1.2, 1.3);
```

上記の計算はrとgとbをそれぞれ1.1倍、1.2倍、1.3倍します。あと、計算式は+=とか*=という代入演算子が使えますのでちょっと短く書くことができます。

```
output.rgb *= float3(1.1, 1.2, 1.3);
```

### 暗くするシェーダ
では描画する画像のα値以外を半分にするシェーダを作ってみましょう。コードは前回とほぼ同じなので、違いがあるピクセルシェーダ本体の部分のみを記載します。

```
float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;

  output = tex2D( Samp0, input );
  output.rgb /= 2.0;
  return output;
}
```

outputに格納されたテクスチャの色情報RGBにたいして、すべてを半分にしています。これで画像が暗くなるはずです。

### 実行してみる

```ruby
require 'dxruby'

hlsl = <<EOS
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;

    output = tex2D( Samp0, input );
    output.rgb /= 2.0;
    return output;
  }

  technique
  {
   pass
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl)
shader = Shader.new(core)

image = Image.new(100, 100, [255, 255, 0])

Window.loop do
  Window.draw(50, 50, image)
  Window.draw_shader(200, 50, image, shader)
end
```

これを実行すると、左のdrawで描画した画像は黄色ですが、右のシェーダで描画した画像は暗い黄色になります。

### まとめ
テクスチャから取得した色に計算式を適用してみました。
SIMDならではの柔軟なデータ操作ができますので、ちょっと面倒な計算もラクラクです。
もっと複雑なものでよく使われる計算は関数としてHLSLが持っているので、それらを調べてみるともっと色々なことができるかと思います。


## RubyとHLSLのデータの受け渡し

今回はRubyのプログラムからHLSLにデータを渡してみます。

### Shader::CoreとShader
チュートリアル初回から使ってはいるのですが、簡単にしか説明していませんでした。
Shader::CoreとShaderはなぜ2つにわかれているのでしょう。
Shader::CoreクラスはHLSLのプログラムを渡してnewします。
このオブジェクトがコンパイルされたHLSLプログラムの実体を持っています。
それに対してShaderクラスはShader::Coreクラスを渡してnewします。
Shaderオブジェクトが持つのはShader::Coreオブジェクトと、そのプログラムに渡す引数の値です。
Window.draw系メソッドへはShaderオブジェクトを渡します。
つまりひとつのShader::Coreオブジェクトで複数のShaderオブジェクトを作り、それぞれ別の引数を保持することができるようになっています。

### 引数の渡しかた
Shader::Core.newは第1引数にHLSLプログラムのStringオブジェクト、第2引数にHLSLプログラムに渡す引数の名前と型のハッシュを渡します。
第2引数のハッシュはkeyが引数名、valueが型となり、引数名はSymbol、型は:float、:integer、:texture、:techniqueのいずれかです。
これらはRuby側から渡す指定であり、HLSL側にも受け取る指定が必要ですが、それは後で説明します。

float4型を渡す場合には型を:floatにして、Rubyの配列でFloatオブジェクトを4個入れて渡します。
floatの配列を渡す場合も同様です。
テクスチャを渡す場合は型を:textureにしてRuby側はImageオブジェクトもしくはRenderTargetオブジェクトを渡します。

実際にHLSLプログラムに渡すデータを設定するには、Shaderオブジェクトの引数名=メソッドを呼び出します。
このメソッドはShader.newしたときに指定したShader::Coreオブジェクトから引数設定を取得し動的に追加されるメソッドですので、Shader::Core.newで指定していない引数のメソッドは存在すらしません。

### 引数の受け取りかた
HLSLプログラムの先頭にグローバル変数を定義します。
その型と名前をShader::Core.newの第2引数に設定してください。
グローバル変数はシェーダ内で自由に参照することができ、Window.draw系メソッドでShaderオブジェクトを渡した際に、Shaderオブジェクトが持っている値が設定されます。


### 塗りつぶしシェーダを作ってみる
ではRGBをRubyから指定して、α以外の要素をその色で置き換える塗りつぶしシェーダを作ってみましょう。

```
// HLSLプログラム

// グローバル変数
float3 rgb;

//シェーダ本体
float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;

  output = tex2D( Samp0, input );
  output.rgb = rgb;
  return output;
}
```

```ruby
# Rubyプログラム
core = Shader::Core.new(hlsl, {:rgb=>:float})
shader = Shader.new(core)
shader.rgb = [0, 255, 255]
```

outputに格納されたテクスチャの色情報RGBを、Rubyから引き渡された色で上書きしています。
これで画像の色が指定色だけになるはずです。
Rubyの配列は整数が入っていますが、:floatを指定した引数はfloat型に自動変換されます。

### 実行してみる

```ruby
require 'dxruby'

hlsl = <<EOS
  float3 rgb;
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;

    output = tex2D( Samp0, input );
    output.rgb = rgb;
    return output;
  }

  technique
  {
   pass
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl,{:rgb=>:float})
shader = Shader.new(core)
shader.rgb = [0, 255, 255]

image = Image.new(100, 100).circle_fill(50, 50, 50, [255, 0, 255])

Window.loop do
  Window.draw(50, 50, image)
  Window.draw_shader(200, 50, image, shader)
end
```

これを実行すると、左のdrawで描画した画像は紫の円ですが、右のシェーダで描画した画像は水色の円になります。

### まとめ
Rubyから色情報を渡してみました。
渡すものは色に限定されません。
座標や画像を渡すこともできます。


## テクスチャ座標について1
今回はテクスチャ座標についてです。

### 描画の仕組み(おさらい)
HLSLのプログラムは画面の1ピクセルにつき1回実行されます。
画面のどのピクセルに描画しようとしているか、という情報は受け取りません。
DirectX側で制御されており、意識しなくてよいためです。

代わりに、どの色を描画しようとしているのか、という情報を受け取ります。
直接色を受け取るのではなく、描画しようとするテクスチャに対するテクスチャ座標という形になります。
HLSLプログラムは引数で受け取ったfloat2の座標を使ってテクスチャを参照し、色を拾ってきて描画するのが基本となります。

```
sampler Samp0 = sampler_state
{
 Texture =<tex0>;
};
float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;
  output = tex2D( Samp0, input );
  return output;
}
```

ここでいうinputというのが引数で、float2の中にxとyがセットで入っています。
この値は(0.0～1.0, 0.0～1.0)で、テクスチャの左上から右下を相対的に表します。
tex2Dという組み込み関数はテクスチャtex0を設定したサンプラSamp0から、inputで表された位置の色をfloat4で取得します。

### 仕組みの応用
つまり、HLSLプログラムが受け取るテクスチャ座標は基本的には(0.0, 0.0)～(1.0, 1.0)の全体をまんべんなく網羅しています。
例外はImage.load_tilesやImage#slice_tilesをshare_switch=trueにして作ったImageで、1枚の画像を部分的に参照しているためテクスチャ座標は半端になります。

さて、このテクスチャ座標を色の生成に利用することで、例えばグラデーションなどを描くことができます。うまいこと計算すればもっと複雑な形状の図を作ることもできるでしょう。

```
sampler Samp0 = sampler_state
{
 Texture =<tex0>;
};

float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;
  output = float4(input.x, input.x, input.x, 1.0);
  return output;
}
```

この例では、出力する色のrgbをテクスチャ座標のxとしています。
左のほうが黒で、右の方が白になるグラデーションを表しています。
また、画像のサイズによらず、全体がグラデーションになります。

### 実行してみる

```
require 'dxruby'

hlsl = <<EOS
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;
    output = float4(input.x, input.x, input.x, 1.0);
    return output;
  }

  technique
  {
   pass
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl)
shader = Shader.new(core)

image = Image.new(640, 480).circle_fill(100, 100, 100, [0, 255, 0])

Window.loop do
  Window.draw_shader(0, 0, image, shader)
end
```

ウィンドウ全体にグラデーションを描画してみました。
描画するImageに円を描いていますが、結果の画面は円などカケラもありませんね。
これはTex2D関数を使わないので、Imageの中身をまったく参照していないからです。
DXRubyではいまのところ描画するときにImageを使う必要がありますので、画像そのものは使わなくても、サイズを指定する意味で画像を渡してやる必要があります。

### まとめ
この方法でトランジション画像が色々作れそうですね。


## テクスチャ座標について2
前回のHLSLプログラムではテクスチャ座標を受け取りました。
テクスチャ座標は引数で渡されて、inputという変数に入るようにしています。
inputの値をいじってやれば、テクスチャの色を取得する位置を変えることができますね。
真ん中が(0.5, 0.5)ですので、例えば

```
input = (input - 0.5) / 2 + 0.5;
```

とすると拡大描画ができます。
ただし画面に対して描画される範囲、つまりHLSLが動作して描画するピクセルは変わりませんので、このようなことをすると普通は画像が描画範囲からはみ出して切れます。

さて、テクスチャを取得する位置が変えられるということは、横にずらしたり縦にずらしたりすることもできます。
が、浮動小数点の0.0～1.0という表現ですので、どれだけずらしたら1ピクセルなのかがわかりません。
HLSLプログラムは描画位置がわからないだけでなく、描画しようとしている画像のサイズもわからないのです。
画像のサイズがわかれば、1.0/サイズで1ピクセルぶんの移動量がわかります。
ですのでこの情報をRubyから渡してあげますと、ピクセル単位の処理ができるようになります。

### 横ローテーションさせてみる
ではRubyからサイズと移動量を渡して、横にずらしてみましょう。はみ出した部分は逆側からでてくるようにして、無限ループさせることにします。

```
float2 size;
float2 d;

sampler Samp0 = sampler_state
{
 Texture =<tex0>;
 AddressU = WRAP;
 AddressV = WRAP;
};

float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  float4 output;
  output = tex2D( Samp0, input - d / size);
  return output;
}
```

サンプラ定義のところにあるAddressU/AddressVというのはサンプラステートといって、テクスチャ座標が(0.0, 1.0)からはみ出した場合にどうするかを表します。
よく使うのが、

* WRAP
  * 反対側から同じ絵を繰り返します
* CLAMP
  * 端の色を繰り返します
* BORDER
  * 透明色にします

という感じです。AddressU/AddressVのUは横、Vは縦方向を表します。
ずらす量をfloat2にしていますので、横だけでなく縦にもずらすことができる仕様になりました。

### 実行してみる

```ruby
require 'dxruby'

hlsl = <<EOS
  float2 size;
  float2 d;
  texture tex0;

  sampler Samp0 = sampler_state
  {
   Texture =<tex0>;
   AddressU = WRAP;
   AddressV = WRAP;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    float4 output;
    output = tex2D( Samp0, input - d / size);
    return output;
  }

  technique
  {
   pass
   {
    PixelShader = compile ps_2_0 PS();
   }
  }
EOS

core = Shader::Core.new(hlsl,{:size=>:float, :d=>:float})
shader = Shader.new(core)
shader.size = [200, 200]

image = Image.new(200, 200).circle_fill(100, 100, 100, [0, 255, 0])

x = 0
Window.loop do
  x -= 1
  shader.d = [x, 0]
  Window.draw_shader(200, 200, image, shader)
end
```

これを実行すると、円の画像が横にスクロールします。

### まとめ
描画する位置はわかりませんが、Ruby側から情報を渡して計算することで作ることができます。
これを応用すると、HLSLで画像をかなり自由に変形させることができるようになるでしょう。


## ラスタスクロールを作ってみる
ラスタスクロールを作ってみましょう。
ラスタスクロールとは画像の行単位でスクロールさせるテクニックで、例えば横スクロールで奥のほうがゆっくり、手前が速いスクロールとか、画像をうねうねと歪ませるなどの効果を作るときに使います。

うねうねさせる場合はDXRubyのRenderTargetクラスを併用する必要があり、やや複雑になります。
せっかくなので今回はうねうねにチャレンジしてみましょう。

### 三角関数を使う
HLSLは三角関数を使うこともできます。
三角関数は普通にsinとかcosとかですが、渡す値はラジアンになっています。
ラジアンは360度を2πとして扱う体系で、イメージしやすい360度系からラジアンに変換するためにradiansという関数も用意されています。

ラスタスクロールは行ごとに違う量を移動させますが、うねうねさせる場合には行単位で角度を変更して三角関数に突っ込んで、出てきた値で横にずらします。
HLSLで書くとこんな感じです。

```
input.x += sin(radians(input.y * 360)) * pixel;
```

この場合ですと、一番上がy座標0.0から始まりますのでsin(0.0)で結果は0.0となり、元の位置に描画されます。
下の行に移るとy座標が少し増えますので、下に行けば行くほど結果は+pixelに近づいていき、yが0.25(90度)になった時が最大でsinの戻りは1.0、x座標のズレは+pixelとなります。
yが0.5(180度)で再び0.0になり、左にズレていき、yが0.75で-pixel、yが1.0で0.0に戻ります。
従って、この計算式で描画しても歪むだけで、リアルタイムにうねうねはしません。

リアルタイムにうねうねさせるためには、スタートの角度をリアルタイムに変更してあげる必要があるので、これはRuby側から渡すことになります。
書き忘れましたがpixelの値もRuby側から渡します。
Ruby側では値を+にしたほうが直感的なので、ずらす値はyから引くことになります。
このへんの計算は実際に動かしていじってみればよく理解できるでしょう。
コードはこのような感じになります。

```
float4 PS(float2 input : TEXCOORD0) : COLOR0
{
  input.x += sin(radians(input.y * 360 - start)) * pixel;
  return tex2D( Samp, input );
}
```

また、このコードでは画像の上から下までで360度となっていますが、360の値を変更することで2周させたり0.5周させたりすることもできます。

### RenderTargetを使う
Shaderで描画する範囲はDXRubyで描画する画像のサイズ内に限定されます。
描画するピクセル単位にHLSLのプログラムが動作するので当たり前であり、この考え方は重要だとこのチュートリアルでも何度も書いてきました。
ラスタスクロールすると絵を横にずらすため、Imageオブジェクトの範囲全体に絵が描かれている場合に、はみ出した部分は描画されないことになってしまいます。
この問題を解決するには、RenderTargetクラスを使います。

具体的にはImageの画像サイズとずらすピクセル数から必要なサイズのRenderTargetオブジェクトを生成し、いったんRenderTargetオブジェクトの真ん中にImageを描画したあとで、それをShaderでラスタスクロール描画します。
はみ出しを考慮した大きなRenderTargetを用意することで、はみ出した部分までHLSLプログラムを走らせることができます。
このような感じです。

```
pixel = 50
image = Image.new(200, 200).circle_fill(100, 100, 100, [0, 255, 0])
rt = RenderTarget.new(image.width + pixel * 2, 200)
```

RenderTargetの真ん中に描画する場合は、描画座標をpixelにすればいいでしょう。

### 実行してみる
```ruby
require 'dxruby'

hlsl = <<EOS
  float start;
  float pixel;
  texture tex0;

  sampler Samp = sampler_state
  {
   Texture =<tex0>;
  };

  float4 PS(float2 input : TEXCOORD0) : COLOR0
  {
    input.x += sin(radians(input.y * 360 - start)) * pixel;
    return tex2D( Samp, input );
  }

  technique
  {
    pass
    {
      PixelShader = compile ps_2_0 PS();
    }
  }
EOS

core = Shader::Core.new(hlsl,{:start=>:float, :pixel=>:float})
shader = Shader.new(core)

pixel = 50
image = Image.new(200, 200).circle_fill(100, 100, 100, [0, 255, 0])
rt = RenderTarget.new(image.width + pixel * 2, 200)

shader.start = 0
shader.pixel = pixel.quo(rt.width)

Window.loop do
  shader.start += 1
  shader.start -= 360 if shader.start > 359

  rt.draw(pixel, 0, image).update
  Window.draw_shader(200, 200, rt, shader)
end
```

これを実行すると、円が横方向にラスタスクロールします。なめらかに気持ち悪いうねうね具合です。

### まとめ
Shaderは画像内のみの処理となりますが、大きめのRenderTargetと併用すればその制限は無くなります。ShaderはRenderTargetとセットになって最大の効果を発揮できるのです。

