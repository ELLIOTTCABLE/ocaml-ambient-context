let basics =
   Test_basics.
     [
       ("can create keys", `Quick, test_create_key);
       ("can set, and get, keys", `Quick, test_set_then_get);
       ("can unset keys", `Quick, test_set_then_unset);
     ]


let test_suite_sync (s : (string * Alcotest_lwt.speed_level * (unit -> unit)) list) :
    unit Alcotest_lwt.test_case list =
   s |> List.map @@ fun (name, speed, f) -> Alcotest_lwt.test_case_sync name speed f


let () =
   Lwt_main.run
   @@ Alcotest_lwt.run "Unix"
        [ ("Basics", test_suite_sync basics); ("all", Test_lwt.suite) ]
