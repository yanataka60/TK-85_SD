# NEC TK-85にSD-Cardとのロード、セーブ機能

　シリアル同期通信によりTK-85とSD_ACCESS(ARDUINO+SD-CARD)とのロード、セーブを提供するルーチンです。


## 必要なもの
　2716×1

　ピンヘッダ等

## 接続方法
Arduino　　　　　　　　　　TK-85

　　5V　　　　　　　-----　　5V　A3
   
　　GND　　　　　　-----　　GND　A1
   
　　9(FLG:output)　　　-----　　PB2(CHK:input)　A32

　　8(OUT:output)　　-----　　PB0(IN:input)　A30

　　7(CHK:input)　　　-----　　PC2(FLG:output)　A40

　　6(IN:input)　　　　-----　　PC0(OUT:output)　A38

## ROMの差し替え

　MONITOR-ROMの内容を読み出し、バイナリエディタ等で以下のファイルの内容に差し替えます。

　　file_trans_TK85(0425H-0555H).bin

　　file_trans_TK85(06E7H-076EH).bin

　ロード、セーブジャンプ先を修正します。

　　02D1～02D2　　DC->25

　　02D4～02D5　　25->28

　キースキャンルーチンを修正します。

　　06C0　　EF->E0

　　06C7　　DF->D0

　　06CE　　BF->B0

　すべての修正が終わったら用意したROMに焼き、装着します。

## 操作方法
　異常が無いと思われるのにエラーとなってしまう場合にはSD-CardアダプタのArduinoとTK-85の両方をリセットしてからやり直してみてください。

### Save
　MODEキー、SAVEキーを押してからファイルNo(xxxx)を4桁で入力してWR/ENTキーを押します。

　正常にSaveが完了するとアドレス部にスタートアドレス、データ部にエンドアドレスが表示されます。

　　　8000H～8390Hまでをxxxx.BTKとしてセーブします。セーブ範囲は固定となっていて指定はできません。

　「FFFFFFFF」と表示された場合はSD-Card未挿入です。確認してください。

### Load
　MODEキー、LOADキーを押してからファイルNo(xxxx)を4桁で入力してWR/ENTキーを押します。

　　　xxxx.BTKをBTKヘッダ情報で示されたアドレスにロードします。ただし、8391H～83FFHまでの範囲はライトプロテクトされます。

　正常にLoadが完了するとアドレス部にスタートアドレス、データ部にエンドアドレスが表示されます。スタートアドレスが実行開始アドレスであればそのままRUNキーを押すことでプログラムが実行できます。

　「F0F0F0F0F0」と表示された場合はSD-Card未挿入、「F1F1F1F1F1」と表示された場合はファイルNoのファイルが存在しない場合です。確認してください。

## 扱えるファイル
　拡張子btkとなっているバイナリファイルです。

　ファイル名は0000～FFFFまでの16進数4桁を付けてください。(例:1000.btk)

　この16進数4桁がTK-85からSD-Card内のファイルを識別するファイルNoとなります。

　構造的には、バイナリファイル本体データの先頭に開始アドレス、終了アドレスの4Byteのを付加した形になっています。

　パソコンのクロスアセンブラ等でTK-85用の実行binファイルを作成したらバイナリエディタ等で先頭に開始アドレス、終了アドレスの4Byteを付加し、ファイル名を変更したものをSD-Cardのルートディレクトリに保存すればTK-85から呼び出せるようになります。

## 実装
　実際の作成したアダプタです。

アダプタの表です。

![SD-Cardアダプタ(表)](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/SD-Card%E3%82%A2%E3%83%80%E3%83%97%E3%82%BF(%E8%A1%A8).JPG)

アダプタの裏です。

![SD-Cardアダプタ(裏)](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/SD-Card%E3%82%A2%E3%83%80%E3%83%97%E3%82%BF(%E8%A3%8F).JPG)

TK-85側のコネクタ部です。

![コネクタ](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/%E3%82%B3%E3%83%8D%E3%82%AF%E3%82%BF.JPG)

実際に装着したところです。

![装着](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/%E8%A3%85%E7%9D%80.JPG)

## 作成例
junk_sugaさんが作成された例です。本体の8255ソケットを利用してスマートに仕上がっています。

![装着](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/junk_suga%E4%BD%9C%E6%88%90%E4%BE%8B(%E8%A1%A8).jpg)

![SD-Cardアダプタ(裏)](https://github.com/yanataka60/TK-85_SD/blob/main/JPG/junk_suga%E4%BD%9C%E6%88%90%E4%BE%8B(%E8%A3%8F).jpg)

## 修正

2021.10.30 TK-85のワークエリアがTK-80より拡大していたことに気付いたため、セーブ範囲とロード時の除外範囲を修正
