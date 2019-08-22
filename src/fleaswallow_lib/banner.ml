(** Putting this in its own file, since it's otherwise messing with the syntax
    * highlighting of whatever file I put it in :-p *)

let print_banner () =
  let () =
    Printf.printf
      {| ,gggggggggggggg
dP""""""88"""""" ,dPYb,                                                             ,dPYb, ,dPYb,
Yb,_    88       IP'`Yb                                                             IP'`Yb IP'`Yb
 `""    88       I8  8I                                                             I8  8I I8  8I
     ggg88gggg   I8  8'                                                             I8  8' I8  8'
        88   8   I8 dP   ,ggg,     ,gggg,gg    ,g,     gg    gg    gg     ,gggg,gg  I8 dP  I8 dP    ,ggggg,    gg    gg    gg
        88       I8dP   i8" "8i   dP"  "Y8I   ,8'8,    I8    I8    88bg  dP"  "Y8I  I8dP   I8dP    dP"  "Y8ggg I8    I8    88bg
  gg,   88       I8P    I8, ,8I  i8'    ,8I  ,8'  Yb   I8    I8    8I   i8'    ,8I  I8P    I8P    i8'    ,8I   I8    I8    8I
   "Yb,,8P      ,d8b,_  `YbadP' ,d8,   ,d8b,,8'_   8) ,d8,  ,d8,  ,8I  ,d8,   ,d8b,,d8b,_ ,d8b,_ ,d8,   ,d8'  ,d8,  ,d8,  ,8I
     "Y8P'      8P'"Y88888P"Y888P"Y8888P"`Y8P' "YY8P8PP""Y88P""Y88P"   P"Y8888P"`Y88P'"Y888P'"Y88P"Y8888P"    P""Y88P""Y88P"

                                                  NKkddolloxxxkOKWW
                                               WKkdlccccccccccccldk0XW
                                             WKxlcclllllllllllllllccco0W
                                           WXxlcllllllllllllllllllllc:ckN
                                          NOocllllllllllllllllllllllllc:xX
                                        NOoclllllllllllllllllllllllllllc:oK
 W0dlcc:cccclodxkO00KXNWMMMMMMMMMMMMWWN0occlllllllllllllllllllllllllllllc:l0W
 Nd'............'',,;cldxOO0KXXXKKK0KK0xddxxdoooollllllllllllllllllllllllc:cOW
 Wx'....................',,;clllccclodddxxO00OO00OkkOkxdddooddoolllllllllllccON
  Kl..........................'',;:::::::ccclloodddxkOOkO0OOO00OkkkxkkkxxxddxxOKXNW
  W0c..............................',;:cclccccccc:::cccclllooodddddxkOOkkOkO00OOkk0NW
   W0c..................................',:cllllllllllcccccccc:::::ccccccccllllooollxkkO0KXNNWWW
    WKl'.....................'',,,,,,,''....';:ccllllllllllllllllllllllllccccccccccccc::ccllooooddddxxxxxkkkkkkkkO000KXN
     WNk:.................',;:clllllllc:;,'....'',:ccllllllllllllllllllllllllllllllllllllllllllccccc::::::::::::;::;,',;
       WKd,..............;:loxkkOkkkkxxxdoc:,'......',;:cclllllllllllllllllllllllllllllllllllllllllllllllllllcc:;,''..'c
         W0l,...........;ldkO000000000000Oxol;'..........',;;::cclllllllllllllllllllllllllllllllllllllcc::;,''.......:kN
           N0o;'.......:odkOO00000000OOOOOOkxo:''''............'',,;::ccccllllllllllllllllcccc::;;;,,''............;xX
             WKxl;''..,oxxO0OO0kolc:;;d0KXXKkxl;,,''''''..............'',,,,,,,,,,,,,,,,,'''....................'cxKW
                NKkdl;:oxkKNXXXO; cKNNNKkxo:;;;;,,,'''''''''''''';;:::::::::;;;;;;;;;;,..................':d0N
                    Nx:lxk0XNNNXx;...:OXNNX0kxl:;;;;;;;;;;,,,,,,,,,;clodxddolccccclllllcccc;..............,cx0N
                    Wk;cdxkKXNNNNX0OKXNNNNKkxdc;;;;;;;;;;;;;;;;;;;;cdxkKXXXKo......cxkkkkxdo;.........,cokKN
                   WXo,;ldxk0KXNNNNNNNNNX0kxdc;;;;;;;;;;;;;;;;;;;;;cdxOXNNNK: cKXNNXOxd:'.',:codOKNW
                 N0xc;;::codxkO0KKKKKK0Okxdl:;;;;;;;;;;;;;;;;;;;;;;cdxOKNNNXk,. .:OXNNNKOxo:,oKXNW
               WKxlcllcc::::loddxxkkkxddoc:;;;;;;;;;:::;;;;;;;;;;;;:oxxOXNNNXKkddOXXNNNKOxdl;:O
              Xkdddxddddoolc::::cccccc::;;;;;;;;;;:looll::;:::::;;;;:oxxO0XXNNNNNNNNNX0kxdl:;:O
             Xkdxxxxxxxdxxxddollc:;;;;;;;;;;;;;;;:odc,:docclolllc:;;;:lodxkO0KKXKKK00Oxdoc::;,lKW
             Xxdxxxxxxdc;codxxxxdoolcc::;;;;;;;:codd;.;ddddl:,,ooc;;;;;:cloddxxkkxxxdolc:;;::;;ckN
             Nkodxxxxxdo:,'';clddxxxxddoollllloodxxdocoxxxxl;,;odo::;;;;;;::ccccccccccccccllooollxKW
              Xkoddxxxxxxdoc;''',:coddxxxxxxxxxxxxxxxxxxxxxddodxxxdolcccccccccccllloooddddxxxxxxdddKW
               Nkccodddxxxxxxdoc;,''',;:clodxxxxxxxxxxxxxxxxxxxxxxxxxddddddddddxxxxxxxxddoolclddxxdkN
                Xl'';cloddxxxxxxxxdoc:;,'''',;:clloddddxxxxxxxxxxxxxxxxxxxxxdddoolcc:;,,'',,;coxxxdON
                 Kc..'',;clodddxxxxxxxxddolc:;,,,''''',,,;;;::::::::::;;;;,,,,,''',,,;;:cloddxxxddxKW
                  Kc.'''.',,;::cloodddxdxxxxxxxddoollc:::;;;;;;,,,,,,,;;;::ccllooodddxxxxxxxddddxOXW
                   Xl''..'''''''',,;:cclooddddxxxxxxxxxxxxxxxxxxxxxddxxxxxxxxxxxxxxxxddddoollokKNW
                    Nx;'co;'''..'''.''',,,,;::ccllooooddddddddddddddddddddddddoooollcc:;;,,,c0W
                     WK0NWKxc;co:'..'',,''..'''''',,,,;;;:::::::::::::::::;;;;;,,,''''...,:dX
                            WXNWKolxo,'';ol,','''''',,,,,,,,,,,'',,',,,,,,,,'',,,''..',,l0NW
                                 WWMN0xx0WNO:',d0o,.'''''',,,,,'',,,,,,,,,,''',,';l::xKXN
                                           WKdkNMNx'.......''';:,'''''','''';;,:xKWNNW
                                                 Wk,.'','''coxKN0olk0x::oolxXXKXW
|}
  in
  Printf.printf "\n%!"
