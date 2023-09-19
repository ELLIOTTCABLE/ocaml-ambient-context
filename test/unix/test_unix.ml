let basics =
   Test_basics.
     [
       ("can create keys", `Quick, test_create_key);
       ("can set, and get, keys", `Quick, test_set_then_get);
       ("can unset keys", `Quick, test_set_then_unset);
     ]


let test_suite_sync (s : (string * Alcotest.speed_level * (unit -> unit)) list) :
    unit Alcotest.test_case list =
   s |> List.map @@ fun (name, speed, f) -> Alcotest.test_case name speed f


let () = Alcotest.run "Unix" [ ("Basics", test_suite_sync basics) ]
