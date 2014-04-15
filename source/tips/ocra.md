# ocraによるexe化
Ruby1.9以降Exerbによるexe化ができなくなりましたが、現在はWindows環境でもocraによるexe化が可能です。
この項目では、ocraによるExeファイルを作成する方法を説明します。

## 基本

### ocraの導入
既にocraが導入済であればこの処理は不要です。
```
gem install ocra
```

### 実行コードの用意
例として、以下のコードをsample.rbという名前で保存します。

```ruby
require 'dxruby'

Window.loop do
  # 何もしない黒い画面が表示されます
end
```


### 実行ファイルを生成する
```
ocra --windows sample.rb
```
`--windows`オプションを付けないとコンソール画面表示後にウィンドウが起動することになります。
上記コマンド実行後、同一フォルダにsample.exeが出力されます。

この方法で作成したexeには、Rubyインタプリタと必要な拡張ライブラリ、ゲームのスクリプトが含まれます。
画像や音のファイルは含まれませんので、配布する場合にはそれらも一緒に配布する必要があります。


## 画像や音も同梱する
生成するexeファイルにスクリプト以外のデータを梱包することも可能です。

### 実行コードの用意
例として、以下のコードをsample.rbという名前で保存し、コードと同じフォルダにimageフォルダを作り、さらにその中にsample.pngを配置します。
ocraは実行時に一時ディレクトリにデータを展開するため、その展開先のスクリプトのファイルパスからの相対位置から読み込むようにする必要があります。

```ruby
require 'dxruby'

$GAME_PATH = File.dirname(__FILE__)
sprite = Sprite.new(0, 0, Image.load("#{$GAME_PATH}/image/sample.png"))

Window.loop do
  sprite.draw
end
```

### 実行ファイルを生成する

```
ocra --windows sample.rb image
```

同梱したいフォルダ名が複数ある場合は、下記のように指定します。

```
# imageフォルダだけでなくsoundフォルダ、scenarioフォルダも含めたい場合
ocra --windows sample.rb image sound scenario
```

### 注意事項
ocraは実行時に一時ディレクトリに実行スクリプト及びその同梱物を展開するため、ゲーム実行中にそこを見ることで露出したソースや画像を確認できてしまいます。
どうしても隠蔽したい、という場合は[このようななにかしらの対策](http://d.hatena.ne.jp/mirichi/20140304/)をする必要があります。

