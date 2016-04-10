(require 'json)
(require 'subr-x)

(defun fix-string (s)
  "Return S, but replace any non-valid utf-8 with ?."
  (string-join
   (mapcar (lambda (ch)
             (or (encode-coding-char ch 'utf-8 'unicode)
                 "?"))
           (decode-coding-string s 'undecided))))

(with-current-buffer (url-retrieve-synchronously "http://gnufans.net/~fsbot/data/botbbdb")
  (goto-char (point-min))
  (re-search-forward "^$")
  (let ((entries nil))
    (condition-case err
        (while t
          (let* ((entry (read (current-buffer)))
                 (name (fix-string (elt entry 0)))
                 (data (elt entry 7))
                 (timestamp (cdr (assq 'timestamp data)))
                 (notes (let ((n (cdr (assq 'notes data))))
                          (if (stringp n)
                              n
                            (format "%s" n))))
                 (parsed (mapcar 'fix-string (read notes))))
            (push `((name . ,name)
                    (timestamp . ,timestamp)
                    (data . ,parsed))
                  entries)))
      (end-of-file
       nil))
    (let ((json-encoding-pretty-print t))
      (write-region (json-encode entries)
                    nil
                    "fsbot.json"))))

