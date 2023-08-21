
(defun myshell (&optional buffer)
  "Call `shell', auto naming buffer from either current directory
of (dired or file name + the first 4 chars of md5 of full path)
or provided name. If prefixed use default `*shell*', if prefixes
twice generate new unique buffer name"
  (interactive
   (cond
    ((equal current-prefix-arg '(16))
     (list
      (read-buffer
       "Shell Buffer: "
       (generate-new-buffer-name (mk-shell-buffer-name)))))
    ((equal current-prefix-arg '(4)) (list "*shell*"))))
  (shell (or buffer (mk-shell-buffer-name))))

(defun mk-shell-buffer-name ()
  (cond
   ((eq major-mode 'shell-mode)
    (replace-regexp-in-string "<.*>" "" (buffer-name)))
   ((eq major-mode 'term-mode)
    (concat "$" (file-name-nondirectory (directory-file-name (cadr (split-string (pwd)))))))
   ((or dired-directory buffer-file-name)
    (let*
	((path (directory-file-name
		(expand-file-name (or dired-directory (file-name-directory buffer-file-name)))))
	 (name (file-name-nondirectory path))
	 (hash (concat (substring (md5 path) 0 4))))
      (concat "$" name ":" hash)))
   ("*shell*")))
