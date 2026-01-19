# gRPC Mock テスト環境

gRPCを利用したユーザークラスにてモックコードを利用するテスト環境。  
gRPCの.protoファイルからコード生成する際、オプション(`--grpc_out=generate_mock_code=true`)で
モックコードを生成することができる。  
本リポジトリは、ビルド環境に Docker コンテナを利用し、コンテナの生成から、  
必要リソース群の取得、ビルドの実行まで行う環境となっている。  
コンテナはエフェメラルに動作(都度起動し終了時に破棄)する。  
また、コンテナ内のユーザー権限はホスト側のユーザーで動作する。

## ファイル構成

```text
test-grpc-mock/
|-- docker/ ....................... x86-64 Ubuntu 開発環境他
|-- cmake/ ........................ CMakeモジュール
|-- src/
|   |-- client.cpp ................ gRPC利用Clientクラス本体
|   |-- client.hpp ................ gRPC利用Clientクラスヘッダー
|   |-- main.cpp .................. クライアントアプリ
|   |-- proto/
|   |   `-- hello.proto ........... gRPC IDLファイル
|   `-- server.py ................. 対向用サーバーアプリ
|-- test/
|   `-- test_client.cpp ........... Clientクラス単体検査プログラム
|-- CMakeLists.txt ................ CMakeファイル
|-- compose.yaml .................. Docker compose による開発環境設定
|-- GNUmakefile ................... Docker compose を使った開発/実行環境の操作用
|-- Makefile ...................... 開発環境上におけるビルド処理(cmake呼び出し)等
`-- README.md ..................... 本書
```

## 環境構成

Ubuntu 24.04コンテナ環境(Docker)に以下のパッケージが導入されている。

- CMake (kiteware)
- gRPC
- Protobuf
- Python向けprotocツール用Pythonパッケージ (grpcio-tools)
- GoogleTest

## ビルド方法

以下を実行する。

```console
make
```

※クライアント単体は `make clinet` 、  
　サーバー単体は `make server` で可能。

`targets/<platform>/install/` 配下にクライアントプログラム(sample-grpc)と
サーバプログラム(server.py)がインストールされる。

```text
targets/x86_64-linux-gnu/install/
`-- bin/
    |-- proto/ ................ サーバー用gRPC由来pythonモジュール
    |-- sample-grpc* .......... クライアントプログラム
    `-- server.py* ............ サーバープログラム
```

## 実行方法

以下を実行する。

```console
$ make launch
docker compose run --rm sdk make -f Makefile  launch
(..略..)/test-grpc-mock/targets/x86_64-linux-gnu/install/bin/server.py &
sleep 1
(..略..)/test-grpc-mock/targets/x86_64-linux-gnu/install/bin/sample-grpc
request.name:  world
response.message:  Hello, world!
Received: Hello, world!
```

あるいは、以下のようにサーバーとクライアントを個別に起動することも可能。

サーバーを起動すると、サーバーが待機状態となる。

```console
docker compose run --rm sdk ./targets/x86_64-linux-gnu/install/bin/server.py
```

次に、別端末から、クライアントを実行する。

```console
docker compose exec sdk ./targets/x86_64-linux-gnu/install/bin/sample-grpc
```

すると、サーバー側とクライアント側で以下のようなメッセージが表示される。

サーバー側：

```console
request.name:  world
response.message:  Hello, world!
```

クライアント側：

```console
Received: Hello, world
```

## gRPC Mockを利用したGoogleTestの単体検査について

以下のコマンドにて単体検査プログラムがビルドされ、  
ctest 経由で実行される。

```console
make test
```

詳細な実行結果を確認する場合は、コンテナ内にて直接実行する。

単体検査プログラム: `./targets/x86_64-linux-gnu/build/sample-grpc-test`

```console
docker compose run --rm sdk ./targets/x86_64-linux-gnu/build/sample-grpc-test
```

以上。
