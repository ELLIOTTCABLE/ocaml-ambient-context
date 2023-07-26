(lang dune 3.6)

(name ambient-context)

(generate_opam_files true)

(source
 (github ELLIOTTCABLE/ocaml-ambient-context))

(authors ELLIOTTCABLE)
(maintainers "ELLIOTTCABLE <opam@ell.io>")

(license MIT)

(package
 (name ambient-context)
 (synopsis "Abstraction over thread-local storage and continuation-local storage mechanisms")
 (depends
  (ocaml
   (>= 4.08))
  ppxlib
  (alcotest :with-test)
  (ppx_bisect :with-test)
  (ocaml-lsp-server :with-dev-setup)
  (ocamlformat
   (and
    :with-dev-setup
    (>= 0.24)
    (< 0.25)))))
