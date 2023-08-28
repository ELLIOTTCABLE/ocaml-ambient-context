ocaml-ambient-context
=====================

This OCaml module provides a API that is type- and dependency-abstracted across thread-local storage, Lwt's [sequence-associated storage](https://github.com/ocsigen/lwt/blob/cc05e2bda6c34126a3fd8d150ee7cddb3b8a440b/src/core/lwt.ml#L727-L751 "Internal documentation for Lwt's SAS mechanism"), and Eio's [fiber-local storage](https://github.com/ocaml-multicore/eio/pull/256 "ocaml-multicore/eio#256, adding a fibre-local storage API") — all different approaches to "throwing" information "across the stack" at runtime, without modifying interleaving methods/components/dependencies.

As a library author, depending on `ambient-context` allows you to

1. abstract some sort of application-provided information into something like "thread-local storage",
2. while still being compatible with dependants who are calling into you from an asynchronous context (like Lwt or Eio),
3. *without* functorizing your interface over (or even depending on!) specifically Lwt or Eio, or preventing non-Lwt/Eio users from consuming your API.

> [!WARNING]
> Ambient context like this — effectively, implicit global state — is usually frowned upon for most uses, and with good reason. This module is *intended* to be used as a last resort, and exclusively for debugging, tracing, and reporting purposes, if at all possible.

Installation and usage ...
--------------------------

The intended usage of this library is in two collaborating components:

1. that of a "deep in the dependency-tree" library `foo-deep-lib`,
2. and a top-of-the-dependency-tree `widget-app`.

The former needs to be able to obtain information from the latter, *without* changing the API presented to intermediate `bar-intermediary-lib` (and equivalently, without changing the function-signatures of intermediate wrappers/callers.)

<a name="as-a-top-level-application"></a>

### ... as a top-level application

When consuming a library that implements `ambient-context`, you'll have to provide the storage-mechanism relevant to the callsite(s) in your application. This will vary depending on *where* you're calling a library that uses `ambient-context` — that is, whether an asynchronous event-loop exists 'above' your callsite on the stack.

**Example:** if you're writing an Lwt-enabled application, and you'll be calling `bar-intermediary-lib` below the `Lwt_main.run` event-loop on the stack, you'll need to install the `ambient-context-lwt` "storage provider":

```diff
 ; dune-project
  (depends
   (ocaml
    (>= 4.08))
+  ambient-context
+  ambient-context-lwt
   bar-intermediary-lib
   (alcotest :with-test)
   (ocaml-lsp-server :with-dev-setup)
```

```diff
 ; src/dune
 (executable
  (name widget_app)
- (libraries bar-intermediary-lib))
+ (libraries ambient-context ambient-context-lwt bar-intermediary-lib))
```

At runtime, your application needs to dictate the relevant storage backend (TLS, Lwt, or Eio) for a delineated section of the stack — usually, this involves wrapping the invocation of your asynchronous thread-scheduler's runloop:

```ocaml
(* src/widget_app.ml *)
module Ctx = Ambient_context

let () =
   let sock = create_socket () in
   let serve = create_server sock in

   (* add this line before [Lwt_main.run]: *)
   Ctx.with_storage_provider (Ambient_context_lwt.storage ()) @@ fun () ->
      Lwt_main.run @@ serve ()
```

To communicate with transitive dependencies, you need an opaque `key` — these are usually created and exposed by your transitive dependency.

You can provide ambient values to the transitive dependency via calls to `Ambient_context.with_binding`; this takes that opaque `key`, the new `value` you want to set, and then a callback:

```ocaml
(* src/widget_app.ml *)
module Ctx = Ambient_context

let () =
   let sock = create_socket () in
   let serve = create_server sock in

   Ctx.with_storage_provider (Ambient_context_lwt.storage ()) @@ fun () ->
      Lwt_main.run @@ fun () ->
      Ctx.with_binding Foo_deep.context_key "my value" @@ fun () ->
         (* This empty [bind] may be necessary; see
            {!Ambient_context_lwt.with_binding}. *)
         Lwt.bind (serve ()) (fun () -> ())
```

> [!NOTE]
> The precise semantics of `with_binding` depend on the chosen storage-backend; refer to your backend's documentation.

### ... as a library

This library allows you to avoid depending on, or functorizing over, `Lwt.t`. In the most basic usage, you simply provide a `Ambient_context.key`, direct your consumers to the [above documentation](#as-a-top-level-application) and then anywhere in your API, you can pull the value 'currently' assigned to your key out of the ambient-context.

You need depend only on `ambient-context` itself, *not* `ambient-context-lwt` or the like:

```diff
 ; dune-project
  (depends
   (ocaml
    (>= 4.08))
+  ambient-context
   (alcotest :with-test)
   (ocaml-lsp-server :with-dev-setup)
```

```diff
 ; lib/dune
 (library
  (name foo-deep-lib)
- (libraries curl pcre)
+ (libraries ambient-context curl pcre))
```

Use `Ambient_context.create_key` to create an opaque key for the value, and expose that to your user:

```ocaml
(* lib/foo_deep.ml *)
module Ctx = Ambient_context

let context_key : string Ctx.key = Ctx.create_key ()

(* ... *)
```

Then, anywhere you like, you should be able to obtain the value assigned to `Foo_deep.context_key` by the consuming application up-stack from you:

```ocaml
(* lib/foo_deep.ml *)
module Ctx = Ambient_context

(* ... *)

let http_request ?headers ?body action url =
   let open Curl in
   let headers =
      match Ctx.get Foo_deep.header_context_key with
      | None -> headers
      | Some header ->
         let header = "x-foo-deep: " ^ header in
         Some (header :: Option.default [] headers)
   in
   (* ... *)
```

Contributing
------------

1. Create an opam switch and install the dependencies:

   ```console
   $ opam switch create . ocaml.5.0.0 --deps-only --no-install

   # If you have opam >= 2.2
   $ opam install . --deps-only --with-test --with-dev-setup

   # ... or with opam < 2.2
   $ opam install . --deps-only --with-test
   $ opam install ocaml-lsp-server ocamlformat
   ```

2. Install [pre-commit][], and then configure your checkout:

   ```console
   $ pre-commit install
   pre-commit installed at .git/hooks/pre-commit
   ```

[pre-commit]: <https://pre-commit.com/index.html#install> "Installation instructions for th pre-commit tool"

License
-------

Copyright © 2023 ELLIOTTCABLE

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
