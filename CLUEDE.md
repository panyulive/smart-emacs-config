# Emacs起動時間の最適化

## 問題の概要

- **初期状態**: 0.6秒前後で起動
- **leaf導入後**: 4秒近く起動時間がかかる
- **目標**: 初期状態と同等の起動速度に戻す

## 調査プロセス

### 1. 環境確認

```bash
# Emacsバージョン
GNU Emacs 30.1

# インストール済みパッケージ
elpa/
└── leaf-4.5.5/
```

### 2. ベンチマーク測定

起動時間の詳細な計測を行うため、`benchmark-init.el`を作成して各ステップの時間を測定:

```
Start: 0.000 seconds
After require package: 3.175 seconds  <- ボトルネック発見！
After package-initialize: 3.180 seconds
After leaf install check: 3.180 seconds
After require leaf: 3.181 seconds
After leaf emacs config: 3.182 seconds
```

### 3. 原因の特定

**`require 'package`で3.2秒**かかっていることが判明。

これはpackage.elの以下の処理に起因:
- パッケージディレクトリのスキャン
- autoloadsファイルの読み込み
- ネイティブコンパイルキャッシュの処理

## 解決策

### 検討した3つのアプローチ

| 方法 | 起動時間 | メリット | デメリット |
|------|---------|----------|-----------|
| **現在の設定** | ~4秒 | package.elが自動で使える | 非常に遅い |
| **package.el完全スキップ** | **0.57秒** | 超高速 | パッケージ管理が手動 |
| **package-quickstart** | ~0.7秒 | package.el使える | 設定が複雑 |

### 採用した解決策: package.el完全スキップ

leafパッケージを直接load-pathに追加し、package.elの初期化を完全にスキップする方法を採用。

```elisp
;; 高速起動版 init.el
;; package.elを使わず、leafを直接読み込む

;; leafのパスを追加(バージョンは適宜更新)
(add-to-list 'load-path (expand-file-name "elpa/leaf-4.5.5" user-emacs-directory))

;; leafを読み込み
(require 'leaf)

;; leafの最小展開を有効化
(setq leaf-expand-minimal t)

(leaf emacs
  :tag "builtin"
  :custom
  (;; バックアップとオートセーブの設定
   (make-backup-files . t)
   (version-control . t)
   (kept-new-versions . 5)
   (kept-old-versions . 1)
   (delete-old-versions . t)
   (auto-save-default . t)
   (auto-save-timeout . 20)
   (auto-save-interval . 200)
   (create-lockfiles . nil))

  :config
  ;; 保存先ディレクトリの設定
  (let ((backup-dir (expand-file-name "~/.emacs.d/backups/")))
    (unless (file-exists-p backup-dir)
      (make-directory backup-dir t))
    (setq backup-directory-alist `((".*" . ,backup-dir)))
    (setq auto-save-file-name-transforms `((".*" ,backup-dir t)))))
```

## 結果

### 起動時間の改善

```
修正前: 4.000秒
修正後: 0.603秒
改善率: 約6.6倍高速化
```

### バックアップファイル

- `init.el.backup`: 元の設定ファイル(package.el使用版)
- `init.el`: 最適化版(package.elスキップ版)

## 今後のパッケージ追加方法

新しいパッケージをインストールする際は、以下の手順を実行:

### 1. package.elを一時的に有効化

Emacs内で `M-:` (eval-expression) を実行し、以下を入力:

```elisp
(progn (require 'package) (package-initialize) (package-refresh-contents))
```

### 2. パッケージをインストール

```
M-x package-install RET パッケージ名 RET
```

### 3. init.elにload-pathを追加

インストールしたパッケージを使えるようにするため、`init.el`に追加:

```elisp
;; 例: company-modeをインストールした場合
(add-to-list 'load-path (expand-file-name "elpa/company-0.10.2" user-emacs-directory))
(require 'company)

;; leafで設定する場合
(leaf company
  :config
  (global-company-mode))
```

### 4. パッケージのバージョン確認

インストール後、elpa/ディレクトリ内のバージョン番号を確認して、load-pathに正しいパスを指定すること:

```bash
ls ~/.emacs.d/elpa/
```

## 参考情報

### 作成したファイル一覧

- `benchmark-init.el`: 起動時間測定用
- `init-solution1.el`: package.el遅延読み込み版
- `init-optimized.el`: 最適化版の初期案
- `init-fast.el`: 最終的な高速版(現在のinit.el)
- `early-init.el`: package.elの自動初期化を無効化
- `fix-native-comp.sh`: ネイティブコンパイルキャッシュクリア用

### その他の最適化アプローチ(未採用)

1. **package-quickstart**: package.elの初期化を高速化するが、設定が複雑
2. **eln-cacheクリア**: ネイティブコンパイルキャッシュの再生成
3. **early-init.el**: package.elの自動起動を無効化

## まとめ

package.elの初期化がボトルネックであることを特定し、leafパッケージを直接読み込むことで起動時間を**約6.6倍高速化**しました。今後パッケージを追加する際は、手動でload-pathに追加する必要がありますが、日常的な起動速度は大幅に改善されています。
