# Smart Emacs Config

高速起動を実現したEmacs設定です。起動時間を約6.6倍高速化しました。

## 特徴

- **超高速起動**: 0.6秒で起動（従来の4秒から改善）
- **シンプルな設定**: leafパッケージを使った読みやすい設定
- **最適化されたバックアップ**: バックアップファイルとオートセーブを一元管理

## パフォーマンス

| 設定 | 起動時間 |
|------|---------|
| leaf導入前 | 0.6秒 |
| leaf + package.el | 4.0秒 |
| **最適化後** | **0.6秒** |

## セットアップ

### 1. 必要なパッケージのインストール

```bash
# Emacsを起動
emacs

# M-: を押して以下を実行
(progn (require 'package) (package-initialize) (package-refresh-contents))

# M-x package-install RET leaf RET
```

### 2. 設定ファイルのクローン

```bash
# 既存の.emacs.dをバックアップ
mv ~/.emacs.d ~/.emacs.d.backup

# このリポジトリをクローン
git clone https://github.com/YOUR_USERNAME/smart-emacs-config.git ~/.emacs.d
```

### 3. leafパッケージのパス確認

leafのバージョンを確認し、`init.el`の5行目を更新:

```bash
ls ~/.emacs.d/elpa/
```

```elisp
;; init.el の5行目を実際のバージョンに合わせて更新
(add-to-list 'load-path (expand-file-name "elpa/leaf-X.X.X" user-emacs-directory))
```

## 設定内容

### バックアップとオートセーブ

- バックアップファイル（`~`）: `~/.emacs.d/backups/`に保存
- オートセーブファイル（`#`）: `~/.emacs.d/backups/`に保存
- ロックファイル（`.#`）: 作成しない
- バージョン管理: 最新5世代、最古1世代を保持

### 高速起動の仕組み

`package.el`の初期化をスキップし、leafパッケージを直接`load-path`に追加することで起動時間を短縮しています。

詳細は[CLUEDE.md](CLUEDE.md)を参照してください。

## 新しいパッケージの追加方法

### 1. パッケージをインストール

```elisp
;; Emacs内でM-:を押して実行
(progn (require 'package) (package-initialize) (package-refresh-contents))

;; M-x package-install RET パッケージ名 RET
```

### 2. init.elに設定を追加

```elisp
;; 例: companyをインストールした場合
(add-to-list 'load-path (expand-file-name "elpa/company-0.10.2" user-emacs-directory))
(require 'company)

(leaf company
  :config
  (global-company-mode))
```

## ファイル構成

```
.emacs.d/
├── init.el          # メイン設定ファイル
├── CLUEDE.md        # 最適化の詳細ドキュメント
├── README.md        # このファイル
└── .gitignore       # Git除外設定
```

## 環境

- **Emacs**: 30.1以上推奨
- **OS**: Linux (WSL2で動作確認済み)
- **必須パッケージ**: leaf 4.5.5以上

## トラブルシューティング

### leafが見つからないエラー

```
Cannot open load file: No such file or directory, leaf
```

leafパッケージがインストールされていないか、`init.el`のパスが間違っています。

**解決策**:
1. `ls ~/.emacs.d/elpa/`でleafのバージョンを確認
2. `init.el`の5行目のパスを実際のバージョンに合わせる

## ライセンス

MIT License

## 参考資料

- [CLUEDE.md](CLUEDE.md) - 最適化の詳細な調査レポート
- [leaf.el](https://github.com/conao3/leaf.el) - 使用しているパッケージマネージャー
