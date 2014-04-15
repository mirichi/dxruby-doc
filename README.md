
# What's this
dxruby用のリファレンスマニュアルを生成するためのスクリプトです。  
外部ライブラリとしてredcarpetを利用しています。  

# How to use
```ruby
ruby make-dxruby-doc.rb [OUTPUT_DIR]
```

以上でOUTPUT_DIRへ各種HTMLが出力されます。  
デフォルトではHTMLフォルダへ出力します。
markdownファイル、doxmeファイルはHTML変換後、OUTPUT_DIRへsourceディレクトリ内部と同一のディレクトリ構成で出力されます。



