;; 高速起動版 init.el
;; use-packageを使用（Emacs 29以降は組み込み）

;; use-packageを読み込み
(require 'use-package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(use-package emacs
  :init
  (global-display-line-numbers-mode)
  :custom
  ;; 1. バックアップ (ファイル名~ ) の設定
  (make-backup-files t)               ; バックアップを作成する
  (version-control t)                 ; 番号付きバックアップを有効化
  (kept-new-versions 5)               ; 最新の保存を5つ残す
  (kept-old-versions 1)               ; 最古の保存を1つ残す
  (delete-old-versions t)             ; 古いバージョンは自動削除

  ;; 2. オートセーブ (#ファイル名#) の設定
  (auto-save-default t)               ; オートセーブを有効化
  (auto-save-timeout 20)              ; 20秒間操作がなければ保存
  (auto-save-interval 200)            ; 200打鍵ごとに保存

  ;; 3. ロックファイル ( .#ファイル名 ) の作成を抑制
  (create-lockfiles nil)

  :config
  ;; プログラミングモードでは折り返しを無効（構造を優先）
  (add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))

  ;; 文章作成（MarkdownやText）では折り返しを有効（読みやすさを優先）
  (add-hook 'text-mode-hook (lambda () (setq truncate-lines nil)))

  ;; 保存先ディレクトリの定義
  (let ((backup-dir (expand-file-name "~/.emacs.d/backups/")))
    ;; ディレクトリが存在しなければ作成
    (unless (file-exists-p backup-dir)
      (make-directory backup-dir t))

    ;; バックアップファイルの保存先を指定
    (setq backup-directory-alist `((".*" . ,backup-dir)))

    ;; オートセーブファイルの保存先を指定
    (setq auto-save-file-name-transforms `((".*" ,backup-dir t)))
    (when (fboundp 'winner-mode)
      (winner-mode 1))
    ;; 使い方:
    ;; C-c <left>  : ウィンドウ配置を戻す (Undo)
    ;; C-c <right> : ウィンドウ配置を進める (Redo)
    (use-package cua-base
      :init 
      (cua-mode 1)
      :config
      ;; C-c や C-x を「選択中だけ」コピペ用のキーとして動作させる設定
      ;; これにより、選択していない時は通常の Emacs コマンド（C-c ...）が使えます
      (setq cua-enable-cua-keys t) 
  
      ;; 矩形編集時に連番を振るなどの高度な機能も有効に
      (setq cua-auto-tabify-rectangles nil) 
      (setq cua-keep-region-after-copy t)
      )
    )
  
  )

;; vterm設定 (Claude Code用)
;; 事前に libvterm が必要: sudo apt install cmake libvterm-dev
(add-to-list 'load-path (expand-file-name "clone-package/vterm-20251119.1653" user-emacs-directory))
(use-package vterm
  :commands vterm
  :custom
  (vterm-max-scrollback 10000)
  (vterm-buffer-name-string "vterm: %s"))

;; inheritenv (claude-code.el の依存)
(add-to-list 'load-path (expand-file-name "clone-package/inheritenv" user-emacs-directory))
(require 'inheritenv)

;; claude-code.el
(add-to-list 'load-path (expand-file-name "clone-package/claude-code" user-emacs-directory))
(use-package claude-code
  :demand t
  :custom
  (claude-code-terminal-backend 'vterm)
  :bind-keymap ("C-c c" . claude-code-command-map)
  :config
  (claude-code-mode))

;; --- 1. Vertico: ミニバッファのUIを縦並びにする ---
(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t)) ; 候補の末尾から先頭にループ

;; --- 2. Orderless: 爆速で柔軟な絞り込み ---
;; スペース区切りで「順不同」に検索できるようになります（例: "mod ver set" で "vertico-mode-setup" がヒット）
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; --- 3. Marginalia: 補完候補に「注釈」をつける ---
;; ファイルサイズ、権限、関数の説明などがミニバッファに表示されます
(use-package marginalia
  :init
  (marginalia-mode))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ; 候補に対してアクション（anythingのTabに相当）
   ("M-." . embark-dwim))        ; 状況に応じた最適なアクションを実行
  :config
  ;; アクション実行後にミニバッファを閉じないなどの設定
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; --- 4. Consult: 検索・移動の拡張ユーティリティ ---
;; AIとの対話で増えたバッファやファイルを瞬時に切り替えるのに必須です
(use-package consult
  :bind (;; オリジナルのコマンドをConsult版に置き換え
         ("C-s" . consult-line)          ; 現在のバッファ内検索
         ("C-x b" . consult-buffer)      ; バッファ・ブックマーク切り替え
         ("M-y" . consult-yank-pop)      ; キルリングの履歴選択
         ("M-g g" . consult-goto-line))  ; 指定行へ移動
  :hook (completion-list-mode . consult-preview-at-point-mode)) ; プレビュー機能

;; --- Magit: Git操作の基盤 ---
(use-package magit
  :bind ("C-x g" . magit-status)
  :custom
  ;; AIが生成した大量の差分でも、Magitのバッファを重くしないための工夫
  (magit-diff-refine-hunk 'all) 
  (magit-save-repository-buffers 'dontask))


;; --- Magit-delta: 差分の視覚的強化 ---
(use-package magit-delta
  :ensure t
  :hook (magit-mode . magit-delta-mode)
  :custom
  ;; deltaの見た目を調整（お好みで）
  (magit-delta-delta-args 
   '("--minus-style" "syntax #3f2222" 
     "--plus-style" "syntax #223f22" 
     "--line-numbers" 
     "--color-only")))

;; Eglot: 標準のLSPクライアント
(use-package eglot
  :ensure t
  :hook ((python-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (go-mode . eglot-ensure)
	 (ruby-mode . eglot-ensure)
	 ) ; AIがよく書く言語を追加
  :config
  ;; エラー箇所を自動でFlymake（エラーチェック表示）に渡す
  (setq eglot-events-buffer-size 0)) ; パフォーマンス向上のため

;; 差分を見ながらエラーを確認しやすくする設定
(use-package flymake
  :bind (("M-n" . flymake-goto-next-error) ; 次のエラーへ
         ("M-p" . flymake-goto-prev-error))) ; 前のエラーへ

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window) ; C-x o を置き換えるのがトレンド
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))) ; ホームポジションのキーで選択

(use-package popper
  :ensure t
  :bind (("C-M-z" . popper-toggle)      ; ポップアップの表示/非表示
         ("C-M-x" . popper-cycle)       ; ポップアップが複数ある時に切り替え
         ("C-M-t" . popper-toggle-type)) ; 通常バッファとポップアップの切り替え
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Help\\*"
          "\\*vterm\\*"  ; vtermもポップアップ管理すると便利
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1)) ; どのポップアップがあるかミニバッファに表示

(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3)
  
  ) ; キーを押してからパネルが出るまでの時間（秒）

;; +++++++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;     langugage
;;
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode)) 

(use-package format-all
  :ensure t
  :hook ((ruby-ts-mode . format-all-mode)
         (go-ts-mode . format-all-mode)
	 )
  :config
  ;; 保存時に自動で、Win+Vで崩れたインデントも全て完璧に直す
  (add-hook 'format-all-mode-hook 'format-all-ensure-formatter))


(use-package go-ts-mode
  :ensure t
  :mode "\\.go\\'"
  :hook ((go-ts-mode . eglot-ensure)              ; 保存時に自動フォーマット
         (go-ts-mode . (lambda ()
                         (add-hook 'before-save-hook #'eglot-format-buffer nil t))))
  :config
  ;; Goはタブ幅8が標準ですが、お好みに合わせて
  (setq tab-width 4))

;; AIが生成したコードのインポート漏れを自動で直す
(use-package go-mode
  :ensure t
  :config
  (add-hook 'before-save-hook 'gofmt-before-save))


(use-package ruby-ts-mode
  :ensure t
  :mode "\\.rb\\'"
  :interpreter "ruby"
  :hook ((ruby-ts-mode . eglot-ensure)
         (ruby-ts-mode . (lambda ()
                           (add-hook 'before-save-hook #'eglot-format-buffer nil t))))
  :config
  (setq ruby-indent-level 2))

;; AIが生成した複雑なブロック構造を可視化する（おすすめ！）
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  ;; Railsプロジェクトを自動認識させる
  (setq projectile-project-search-path '("~/projects/" "~/work/")))

;; Rails専用の移動コマンド（C-c r m でModelへ、C-c r c でControllerへ等）
(use-package projectile-rails
  :ensure t
  :config
  (projectile-rails-global-mode))

(use-package inf-ruby
  :ensure t
  :hook (ruby-ts-mode . inf-ruby-minor-mode))


;; 追加のパッケージをインストールする場合:
;; 1. package.elを使う場合:
;;    M-x package-install でパッケージをインストール
;;    use-package宣言に :ensure t を追加すると自動インストール可能
;; 2. 手動で管理する場合:
;;    clone-packageディレクトリにダウンロードして load-path を追加
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ace-window consult embark embark-consult format-all go-mode
		magit-delta marginalia orderless popper
		projectile-rails rainbow-delimiters treesit-auto
		vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
