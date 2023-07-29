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
 (synopsis
  "Abstraction over thread-local storage and continuation-local storage mechanisms")
 (depends
  (ocaml
   (>= 4.08))
  (alcotest :with-test)
  (bisect_ppx :with-test)
  (ocaml-lsp-server :with-dev-setup)
  (ocamlformat
   (and
    :with-dev-setup
    (>= 0.24)
    (< 0.25)))))

(package
 (name ambient-context-lwt)
 (synopsis
  "Storage backend for ambient-context using Lwt's sequence-associated storage")
 (depends
  (ocaml
   (>= 4.08))
  lwt
  (alcotest :with-test)
  (bisect_ppx :with-test)))

(package
 (name ambient-context-eio)
 (synopsis
  "Storage backend for ambient-context using Lwt's sequence-associated storage")
 (depends
  (ocaml
   (>= 5.0))
  eio
  (alcotest :with-test)
  (bisect_ppx :with-test)))
