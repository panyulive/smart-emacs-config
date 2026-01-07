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
  (;; 1. バックアップ (ファイル名~ ) の設定
   (make-backup-files . t)               ; バックアップを作成する
   (version-control . t)                 ; 番号付きバックアップを有効化
   (kept-new-versions . 5)               ; 最新の保存を5つ残す
   (kept-old-versions . 1)               ; 最古の保存を1つ残す
   (delete-old-versions . t)             ; 古いバージョンは自動削除

   ;; 2. オートセーブ (#ファイル名#) の設定
   (auto-save-default . t)               ; オートセーブを有効化
   (auto-save-timeout . 20)              ; 20秒間操作がなければ保存
   (auto-save-interval . 200)            ; 200打鍵ごとに保存

   ;; 3. ロックファイル ( .#ファイル名 ) の作成を抑制
   (create-lockfiles . nil))

  :config
  ;; 保存先ディレクトリの定義
  (let ((backup-dir (expand-file-name "~/.emacs.d/backups/")))
    ;; ディレクトリが存在しなければ作成
    (unless (file-exists-p backup-dir)
      (make-directory backup-dir t))

    ;; バックアップファイルの保存先を指定
    (setq backup-directory-alist `((".*" . ,backup-dir)))

    ;; オートセーブファイルの保存先を指定
    (setq auto-save-file-name-transforms `((".*" ,backup-dir t)))))

;; 追加のパッケージをインストールする場合:
;; 1. M-x eval-expression (または M-:)
;; 2. (progn (require 'package) (package-initialize) (package-refresh-contents))
;; 3. M-x package-install でパッケージをインストール
;; 4. このファイルに load-path を追加して require
