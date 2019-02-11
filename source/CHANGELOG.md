# 更新履歴

## DXRuby
* 2019/02/11 1.4.6
  * エラーメッセージが環境によって文字化けするので英語にしました。
  * Ruby2.4用以降のコンパイラをRubyInstaller2のDevkit(MSYS2)に変更しました。
  * ゲームコントローラが繋がっていない場合にキーリピート機能がうまく動かない不具合を修正しました。
  * Font#infoのgm_blackbox_xが正しく取得できない不具合を修正しました。
* 2016/09/18 1.4.5
  * Window.draw_boxを呼ぶとSEGVすることがある不具合を修正しました。
  * Sprite#offset_sync=true時の衝突判定エラーチェックを修正しました。
* 2016/05/07 1.4.4
  * Window.resizeが失敗することがある不具合を修正しました。
* 2016/05/07 1.4.3
  * パーリンノイズを生成するメソッド、Image#perlin_noise/octave_perlin_noise/custom_perlin_noise/perlin_seedを追加しました。
  * Font.newのオプションに:auto_fittingを追加しました。Font#auto_fittingを追加しました。
  * RenderTargetがGCに解放された場合にたまにSEGVする不具合を修正しました。
  * ウィンドウ外へのドラッグ後にボタン解放が正しく認識できなかった不具合を修正しました。
  * フルスクリーンからウィンドウモードに変更した際にTOPMOST設定がされていなかったので設定を追加しました。
* 2015/09/06 1.4.2
  * 内部UTF16化で表示できなかった文字ができるようになりました。
  * デフォルトアイコンを設定しました。
  * 衝突判定配列がネストできるようになりました。
  * Window.loopが複数置けるようになりました。Window.loopに引数close_cancelを追加しました。
  * Window.created?/closed?/close/ox/oy/ox=/oy=/draw_pixel/draw_box/draw_circle/draw_circle_fill/full_screen=/full_screen?追加。
  * 既存のメソッドInput.mouse_pos_x/yのalias、Input.mouse_x/yを追加しました。
  * Font#name追加。
  * Image#change_hlsバグ修正。
  * Input.requested_close?追加。
  * Sound.load_from_memory、Sound#pan/pan=/frequency/frequency=追加。
  * Sprite.checkのコールバックメソッドに引数が無くても動くようにしました。
* 2014/03/09 1.4.1
  * ウィンドウのタイトルをマウスで掴んでも止まらなくなりました。
  * RenderTargetオブジェクトを画面や別のRenderTargetオブジェクトに描画する際、自動的にupdateされるようになりました。
  * Window.running_time/before_call/after_call/folder_dialog/get_current_mode/draw_box_fill追加。
  * RenderTarget#resize/ox/ox=/oy/oy=/draw_box_fill追加。
  * Image#flush/effect_image_font/change_hls、Font.install/default/default=、Font#info追加。
  * Sprite#offset_sync/offset_sync=、Input.set_cursor/key_release?/pad_release?/mouse_release?追加。
  * SoundEffect#save追加。
  * 他バグ修正たくさん。
* 2012/08/29 1.4.0
  * Shader/Spriteクラス追加。
  * Inputモジュールにアナログパッド入力メソッド追加。
* 2012/07/21 1.2.3
  * Window.draw_line追加。
  * Window.get_screen_shotの拡張子自動判別対応。
  * メソッドの引数が多い場合のエラーチェック追加。
  * Window.draw_exのハッシュキーにscale_x/y/center_x/yを追加。
  * 回転などの描画時にゴミが描画されることがある不具合の修正。
  * 色定数C_BLACK/C_RED/C_GREEN/C_BLUE/C_YELLOW/C_CYAN/C_MAGENTA/C_WHITE/C_DEFAULT追加。
  * Image#triangle/triangle_fill/clear追加。
  * Image#saveをImageが表す部分のみ保存するよう修正。
  * Image.load_to_array、Image#slice_to_arrayにそれぞれ別名load_tiles、slice_tilesを定義。
* 2012/05/06 1.2.2
  * Image#circle/circle_fillの描画アルゴリズム変更。
  * RenderTargetへの描画時のα合成式変更。
  * Window/RenderTarget#draw_tileの内部処理修正。
  * Window/RenderTarget#decide/discard追加。
  * RenderTarget/Image/Font/Sound/SoundEffectにdisposed?追加。
  * Window/RenderTarget#draw_exの:blend指定に:none追加。
  * Image#saveの拡張子自動判別追加、PNGファイルサポート。
  * Input.pad_num追加。
  * ENDブロックでGCが発生するとSEGVする不具合修正。
  * Image#slice、Image#slice_to_arrayで新規テクスチャを作成するよう修正。
  * Image#width=/height=/texture_x/texture_y/texture_x=/texture_y=廃止。
* 2012/03/24 1.2.1
  * Window.drawFontEx、Image#drawFontEx/delayed_dispose、Font.fontname/italic/wightメソッド追加。
  * RenderTarget#width=/height=/texture_x/texture_x=/texture_y/texture_y=メソッドを廃止。
  * Windowモジュールの拡大縮小フィルタをウィンドウ生成前に設定するとエラーになる不具合を修正。
  * Ruby1.9.1以降で文字エンコードの制限を撤廃。
  * Image#draw/drawFontの色計算不具合修正。
  * RenderTarget.newでbgcolorの指定が無視されている不具合修正。
* 2011/10/02 1.2.0
  * RenderTargetクラスを追加。
  * Window.setViewPortメソッドを廃止。
  * Window.drawMorphメソッドを追加。
  * Image/Sound/SoundEffect/Fontクラスにdisposeメソッドを追加。
  * Window.getScreenShotでウィンドウが画面から出ている場合にエラーになる不具合を修正。
  * ライセンスをzlib/libpngライセンスに変更しました。
* 2010/06/02 1.0.9
  * Window.resize/active?/getScreenModesを追加。
  * Image#slice_to_arrayを追加。
  * Image#dup/cloneをRuby的に正しく動作するよう修正。
  * Ruby1.8.6以前に対応。
  * 全角/半角キーでIMEが起動してしまう不具合修正。
  * Font#getWidthにString以外のオブジェクトを渡すと異常終了する不具合修正。
  * Window.loop中のInput.updateをエラーにするよう修正。
  * 外部I/Fが無くなってしまっていたのを修正。
* 2010/02/26 1.0.8
  * 各クラスのinitializeをprivate_methodに変更。
  * Window.setViewportが正常に動作しない不具合を修正。
  * フォントハンドルを開放しない不具合を修正。
  * フルスクリーン化した状態でALT+TABすると切り替えができなくなる不具合を修正。
  * Window.drawExの実行速度を改善。画像の描画速度を全体的に改善。
  * ウィンドウにフォーカスが無い場合でもSoundEffectオブジェクトの音が再生されるよう修正。
  * Window.drawTileのマップデータが空の場合に強制終了される不具合を修正。
  * Font.newの:weight指定にtrue/falseが使えるよう修正。
  * アンダースコア区切りのメソッド名を全メソッドに定義。
  * Input.setMousePosを追加。
* 2009/11/07 1.0.7
  * Font.newにオプションで:weight、:italic指定を追加。
  * 自前ループ時にウィンドウのクローズをキャンセルするように修正。
  * Window.drawExのオプションに:sub2追加。
  * Window.drawFontの文字列を束縛するよう修正。
  * Soundクラスのループ設定関連の不具合修正。
  * Sound.newでファイルが無いときにSEGVしていた不具合を修正。
  * Image#texture_x/texture_y/texture_x=/texture_y=/width=/height=追加。
* 2009/07/25 1.0.6
  * Window.drawTileの不具合修正。Window.draw系メソッドでImageオブジェクトを束縛するよう修正。
  * Image#drawFont、Image#drawでの半透明色計算誤りを修正。
  * Image#dup、Image#clone、Font.install、Font#size、Input.keys、Input.pads追加。
  * Windowモジュールに各種ゲッターを追加。
* 2009/07/16 1.0.5
  * Window.windowedを実行中切り替え可能に。状態取得メソッドWindow.windowed?追加。
  * Window.loadIcon、Window.drawTile、Input.setKeyRepeat、Input.setPadRepeat、Image#setColorKey、
  * Image#save、Image#slice、Image.loadFromFileInMemory、Font#getWidth追加。
  * Image.slice削除。Sound#playを削除、Sound#bgmplayをSound#playに名称変更。
  * Window.setViewport、Image.loadの不具合修正。
  * 外部拡張ライブラリインターフェイス追加。
  * i845チップセットで動作しなかったため、バックバッファフォーマットをUNKOWNに変更。
  * Window.drawEx、Window.drawFontからAddキー削除。Image#boxを塗りつぶさない四角形描画に変更。
  * 色配列をα無しの3要素[r, g, b]でも指定可能に修正。
  * Input.setConfigで設定したキーとパッドの関連を、キーの判定にも反映されるように修正。
  * また、nil指定で解除できるよう修正。
  * 画像保存フォーマットにFORMAT_DDS追加。
  * DXRubyモジュールを定義、全クラス・モジュール・定数をその下に定義し、自動でincludeされるように修正。
  * require 'dxruby'の前に$dxruby_no_include=trueを書けば自動includeされなくなるようロジックを追加。
  * DXRuby::VERSIONを定義。
  * SoundEffect#addのwavetypeを省略可能に。
  * SoundEddect.newとSoundEffect#addのブロック戻り値の周波数をInteger→Floatに変更。
  * キーコード定数にDirectInputの全てのキーを定義。
* 2009/06/14 1.0.4
  * フォント描画時のキャラセットをDEFAULT_CHARSETに変更。描画性能向上。
  * Image#copyRect、Image#drawのエラーチェック追加。Image#drawFontのアンチエイリアス処理追加。
  * ウィンドウに最小化ボタン追加。Window.hWnd、Window.x、Window.y、Window.width、Window.height追加。
  * フルスクリーン時にWindow.getLoadの値がおかしくなる不具合、FPS計算式修正。
* 2009/05/28 1.0.3
  * Image.load引数変更
  * Window.create、Window.update、Window.sync、Window.minfilter=、Window.magfilter=、Window.setViewport、
  * Window.drawSub、Image.slice、Image#copyRect、Image#draw、Image#drawFont、Image#boxFill、Image#fill、
  * Input.update追加
  * Window.drawEx、Window.drawFontに:blendキー追加
  * コンパイラの最適化オプション有効化
  * Image#lineアルゴリズム修正
* 2009/05/18 1.0.2
  * Intel915/945シリーズの内蔵グラフィックス使用PCで動作しない不具合修正
* 2009/05/16 1.0.1
  * インストーラ不具合修正
* 2009/05/15 1.0.0
  * 安定版リリース、ライセンスをMITライセンスに変更
* 2009/05/09 0.0.9
  * GC負荷安定、エラーチェック強化、ウィンドウのフォーカスが外れた時の処理追加
* 2009/05/06 0.0.8
  * フォント描画の効果追加、FPS制御修正
* 2009/05/04 0.0.7
  * Image描画をD3DXSpriteから自前描画に変更して描画性能向上
* 2009/04/23 0.0.6
  * Soundクラスの各種制御機能追加、加算合成対応、キー入力オートリピート機能追加
* 2009/04/19 0.0.5
  * SoundEffectクラス追加
* 2009/04/15 0.0.4
  * Image.newをImage.loadに変更、Image.newは透明色のみのイメージ作成へ変更。Input.xxxPush?追加
* 2009/04/12 0.0.3
  * Fontクラス追加、Imageオブジェクト編集機能追加
* 2009/04/06 0.0.2
  * 不要なメソッド削除などの簡素化を行い、SourceForge.jpにて公開
* 2005/未明  0.0.1
  * プロトタイプ完成
