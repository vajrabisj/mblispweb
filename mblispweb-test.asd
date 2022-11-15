(defsystem "mblispweb-test"
  :defsystem-depends-on ("prove-asdf")
  :author "michael bi"
  :license ""
  :depends-on ("mblispweb"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "mblispweb"))))
  :description "Test system for mblispweb"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
