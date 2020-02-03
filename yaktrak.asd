(asdf:defsystem #:yaktrak
  :description "Yak shaving assistant"
  :author "Ben Spencer <dangerous.ben@gmail.com>"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on (#:uiop #:cl-ansi-term)
  :components ((:file "package")
               (:file "yaktrak")))
