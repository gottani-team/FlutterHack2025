# セットアップガイド

このプロジェクトはFlutterのワークスペース機能とmiseによるバージョン管理を使用しています。

## 前提条件

- [mise](https://mise.jdx.dev/) がインストールされていること
- miseのシェル統合が有効になっていること

## セットアップ手順

### 1. miseのインストール確認

```bash
mise --version
```

### 2. プロジェクトの設定ファイルを信頼

初回セットアップ時、miseが設定ファイルを信頼する必要があります：

```bash
mise trust
```

### 3. Flutterのインストール

```bash
mise install
```

これにより、`.mise.toml`で指定されたFlutterのバージョンがインストールされます。

### 4. 依存関係のインストール

```bash
# ルートディレクトリから実行（ワークスペース全体に適用）
flutter pub get
```

### 5. コード生成（必要に応じて）

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. アプリの実行

```bash
cd app
flutter run
```

## miseの使い方

### バージョンの指定

`.mise.toml`ファイルでFlutterのバージョンを指定できます：

```toml
[tools]
flutter = "3.24.0"  # 特定のバージョンを指定
# または
flutter = "latest"  # 最新版を使用
```

### よく使うコマンド

- `mise install` - 指定されたツールをインストール
- `mise list` - インストール済みのツールとバージョンを表示
- `mise trust` - 設定ファイルを信頼
- `mise update` - ツールを最新版に更新

### 自動環境有効化

miseのシェル統合が有効になっている場合、プロジェクトディレクトリに入ると自動的にFlutterの環境が有効化されます。

## トラブルシューティング

### miseが設定ファイルを信頼しない場合

```bash
mise trust
```

### Flutterが見つからない場合

1. `mise install` を実行してFlutterをインストール
2. シェルを再起動するか、`mise activate` を実行
3. `which flutter` でFlutterのパスを確認

### ワークスペースが認識されない場合

ルートディレクトリの`pubspec.yaml`に`workspace`セクションが正しく設定されているか確認してください。

