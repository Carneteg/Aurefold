-- Hash-only baseline for The Bell of Silence — English Master v1.6.
-- No manuscript prose is stored here.
do $$
declare
  v_version uuid;
  r record;
  v_section uuid;
  v_scene uuid;
begin
  update public.manuscript_versions set is_current=false where book_code='book-1';

  insert into public.manuscript_versions(book_code,version_label,source_filename,source_sha256,parser_version,word_count,section_count,is_current,import_status,notes,metadata)
  values ('book-1','English Master v1.6','Aurefold_The_Bell_of_Silence_English_Master_v1.6.md','41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b','aurefold-manuscript-sync-v1',105048,48,true,'baseline',
          'Current governing working master baseline. Hash-only import; prose remains outside the database.',
          jsonb_build_object('word_count_method','sync-parser-v1','revision_status','active_revision'))
  on conflict (book_code,version_label) do update set source_sha256=excluded.source_sha256, source_filename=excluded.source_filename,
    parser_version=excluded.parser_version, word_count=excluded.word_count, section_count=excluded.section_count, is_current=true,
    import_status='baseline', notes=excluded.notes, metadata=excluded.metadata
  returning id into v_version;

  for r in
    select * from (values
      ('b1-ch-01','chapter',1,1,'Chapter One','The Trial of the Goatherd',11,361,2687,'115c9afaab71930223cded004fbd2bfc5ac1d2b921ea20734ad98f49cb37114e','f45e453ae4fc0219bf801079f46a1de5f21137cdc2198c86abec2066d75b0f1c'),
      ('b1-ch-02','chapter',2,2,'Chapter Two','The Woman Against the Stone',362,476,1112,'0c33b8a2d3583cb85512a06bd5faf1107d660db7df0971cb1ee64c35399a42af','f4ee4de1f0876267b0ff45c9d015b3f6f69e41215f3f7d918f3eeb5774b263aa'),
      ('b1-ch-03','chapter',3,3,'Chapter Three','The Morning After',477,965,3084,'b418d024d8e7efa628b6772c0cf3a71fc4363fb8bfbee0f79982a653d8799941','2bd9475471bdbe9a3fda9635975d64ee48aff62a58aee90a0bded60b7c709a16'),
      ('b1-interlude-01','interlude',null,4,'Interlude','The Question in the Margin',966,1268,2029,'b67adecf66f1251ecb66956da72b9fdc7ac31ff4ff533f57444841c92ac8ef4c','d175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613'),
      ('b1-ch-04','chapter',4,5,'Chapter Four','Harl''s Road',1269,1703,3369,'a381d5919fb06e828e872ad2871947af240b57115128596ebb0b522b215904cc','6b87141af9aeefd0272ec2df0932d318028c5749fbfc5e1ad086a99d314026cb'),
      ('b1-ch-05','chapter',5,6,'Chapter Five','The Ledger',1704,2244,3096,'08dbc339788c08285c397e9e32893b58b60ae7adda4351965066bdcf6e3e85b9','fa053394e0aa4ed85d49ef5b8f267244da5a87c4fd356dcebee6fe78ab7075b1'),
      ('b1-ch-06','chapter',6,7,'Chapter Six','Col',2245,2638,3085,'ec2fc610b8887b2505a9c10e35d50c51573adfda2c25d1e1360423e8b63c4495','4c730ad1ac6b6c59db7725c437661c211473b336fa6fe0cd078adad3a362b6e1'),
      ('b1-ch-07','chapter',7,8,'Chapter Seven','The East Shoulder',2639,2943,2591,'5daf925ebea8452dfd9cdec92519a8939bb5b1959870f65d90b2cf8bff45782d','228b2f71358d6e40f4365b31798f637bcb3446527018ca8916d4ef7e4df6eaba'),
      ('b1-ch-08','chapter',8,9,'Chapter Eight','Nothing Happened',2944,3252,2310,'dbdb56180ddee367bc5eecd4982e93d5e42ca1ddcbb7bb033e0f3ef1fc3e60b3','71fa2a4529d5d2e590c57731a4624a56a9605cf0a667ee4f058ddaf41c3175af'),
      ('b1-ch-09','chapter',9,10,'Chapter Nine','The Man Who Writes It Down',3253,3609,2562,'0ae6c384430a4f4a4ca10189a41052e9e6f7d1bc910e4253ab0409818843f4db','b56297772f297919c6358c98d9b0b5d92822c907130067ecfa8a87730cabd0b9'),
      ('b1-ch-10','chapter',10,11,'Chapter Ten','Nobody Ever Asked',3610,3940,2204,'a17f6459f8cf8f22accba8a9594d038fd6f7b80e92ecf5083df22b9407afa524','c5fe72c45b4b4a5fee992f743912c54d9045fb527ed0ec848c4ff50780b5f995'),
      ('b1-ch-11','chapter',11,12,'Chapter Eleven','What the Grave No Longer Shows',3941,4329,2357,'6bed26c9b256d3b9524f843fedb59ab8c5fff49df2fdb007a1431c16315023c9','1de0a1a6de796fb49e932cc35c5c4481df07696215eb70fbd17a6e5ca73bba9a'),
      ('b1-ch-12','chapter',12,13,'Chapter Twelve','Fen Who?',4330,4676,1572,'ae9e9ad128892deaa77ac262b3f739fbc9eb93be9746626331660e5b1ed2c558','962d5e9381d2be5a30d1fe24d82acf022455b206ea5f2c30b814105353b460f7'),
      ('b1-ch-13','chapter',13,14,'Chapter Thirteen','The Corrected Entry',4677,5023,2274,'f7885e14a0f9fbdf10fe2c58b591d321fcaf317a4e980807c17fac17db5819e5','c12ba0b513495cece0a56f6d4a524c73fd84f6d4e455805b7ca29f03ab5e4d66'),
      ('b1-ch-14','chapter',14,15,'Chapter Fourteen','Not That Way',5024,5348,2161,'8097896504adbc15299b9b3c2796c082df281957a80c9f6bedf399c6c011be0c','ad7af2a7bcaddec9f63e9d45a747be65c1ae07aa58e032735e610aeb9fd2934c'),
      ('b1-ch-15','chapter',15,16,'Chapter Fifteen','Nine Fares',5349,5675,2272,'607eca31d05812cc92360a4cc22e010e884dabab966ea646e15ce09ef5e0de28','557b67c365d52dc08861c515cfa5d3df165b8bb866abdee575fd2a219f2f156e'),
      ('b1-ch-16','chapter',16,17,'Chapter Sixteen','Four Accounts of a Rope',5676,5946,2154,'776f6c05925c4d71f73910c66bda3923d86ea5afae346a994285987d187800ea','dfd306f5b1f48674836906751923be9b7a05ab2671cbcc0e583b653695e73f89'),
      ('b1-ch-17','chapter',17,18,'Chapter Seventeen','What Harl Became',5947,6271,2269,'a8ff9d9f0ffee87116cf49ad3ddea0fa1ccb7af23ff6a24048fdef8078b2b791','7d6ffae98bb285e26c7613ca646a348513f7be487b9007b56eee2c7b637a1c1d'),
      ('b1-ch-18','chapter',18,19,'Chapter Eighteen','The Rule of Six Words',6272,6562,2232,'5d70782720ee4910c59af04ffc88dab921bd65d3966c6cfb54d0c0d916bd3104','bf23735a6664b95f92ffe715c6f21cb2d31d61e2b5ab27a5704433e01981bc5e'),
      ('b1-ch-19','chapter',19,20,'Chapter Nineteen','Lethren',6563,6986,2857,'d4f392a263aae42c11a3cb5e7ab7a611182a33c6d8dfdce0b376f1a0fbc19f3d','11316a3bc9476eebd0ca81e362e80b7f27a159e15f5f91d0e6d3e730c994ec1f'),
      ('b1-ch-20','chapter',20,21,'Chapter Twenty','Serenel',6987,7727,2960,'5f99bb78d383b4fcdd4f917cd4f814a9bc85c1502e69f5fae7a91c50ff8f99fb','a690e88d3fc5bddb350d1156663a34e1ea609cdc1f42fc7bd1dbe14037f0fb5d'),
      ('b1-ch-21','chapter',21,22,'Chapter Twenty-One','The Price of Water',7728,8320,5064,'c7a9771cb23773dc3f3d6bdb535bbf91a5ed0d6674345209ddaa315b473d0930','1a635661d0189027102057e2c0773e50e5a27100a8d270a4ea139d1462936454'),
      ('b1-ch-22','chapter',22,23,'Chapter Twenty-Two','What She Never Told Him',8321,8677,1362,'3043246584487cfbc09667b2e195ec8964eb9564f8d6ea4ae178cab301da6bff','d7836d967e903e33e02428c8d0726c684e4b0b2903388bacba91cd46b625a12c'),
      ('b1-ch-23','chapter',23,24,'Chapter Twenty-Three','You Knew What They Would Hear',8678,9006,1405,'464877d7409dcdf5d0547fd2097f03453fcb34c5d3a5017674a830a675034c32','c12328244d14b0f2c80debfbdfed6c3dcabb15d65f733cf8ac38ace0b163cae2'),
      ('b1-ch-24','chapter',24,25,'Chapter Twenty-Four','The First Command',9007,9443,1570,'6bfaa34a3455d7ca58ec262d9e4e4517b96592351258464ee5a124edb4e6431a','46e67a3a3f182f8ae841d7ca2df93856994e58a58b7760afcdc1b7e0ac305739'),
      ('b1-ch-25','chapter',25,26,'Chapter Twenty-Five','Two True Messages',9444,9920,2546,'970ceee3e73577ab24cee8f5c8556fe66e37451578cb8e1a2367d550a9ad15ed','cf31b2a5b052ac61fb34d0886ecf353a5ceb9b18f1102f657813bb6084268d11'),
      ('b1-ch-26','chapter',26,27,'Chapter Twenty-Six','The Agreement That Almost Worked',9921,10267,1496,'f478b2883d8cac50e7ff5cd8ead2b61e4846412a9cc245f6124b4418b999ae86','7d974ff234dc2a846ccfbec7d13ed3eeed136da2dd2a116ebaa3c423506d1f37'),
      ('b1-ch-27','chapter',27,28,'Chapter Twenty-Seven','Before the Field',10268,10660,1378,'6856fd5fe8afad0bd91fcfb46b73cebca2d676d1f61f79097c305e2d344461be','02c0c598ccf6f1aa04af795277c003f9732c2fdd2dee586c94b7851138813606'),
      ('b1-ch-28','chapter',28,29,'Chapter Twenty-Eight','The First Arrow',10661,10923,1321,'32d96f992585b9c18df0f558b152ccdff5bd082b337a40b6f3911cf22f2e6107','77ea25552ca26b92956a02146c47bb85d367e6ca9301dda98ac0d54a52144684'),
      ('b1-ch-29','chapter',29,30,'Chapter Twenty-Nine','Lower Field',10924,11292,1483,'280453a583d4bd7f4851973b5c5aed8383c37ec411419712def42c563065dad7','6beab8c75a3d4ecebd433b6fff2d2c82765db1972629fb91ae2b7027d59ad76b'),
      ('b1-ch-30','chapter',30,31,'Chapter Thirty','The Line That Held',11293,11717,1688,'48322e687280e8c77f9018bcba4b3ac708483faa838b9b8974e86254d53a9d92','78ae2825894dea7d0f1f966c97fed8a59baa4d772a8ab29f415afe6255110213'),
      ('b1-ch-31','chapter',31,32,'Chapter Thirty-One','The Man Under the Banner',11718,12090,1287,'82a0774411368916c3705cfeb14d60a1d85c770b5cca39c0b03f0654279d5311','8b9695ca4c146c4c15646f8c7bdb6d862d16eac4d0bedbbeafc9e7f57be3cd99'),
      ('b1-ch-32','chapter',32,33,'Chapter Thirty-Two','Who Won',12091,12435,1342,'f7a7ba3b58edac29530a8e6197e9a879704615c84f97f61e56c63d370e538442','7c6485abe0fcb7183640950a448d7c0ebd1431c4fabb1cf8d0aa7f5a40cde808'),
      ('b1-ch-33','chapter',33,34,'Chapter Thirty-Three','The Dead Have Owners',12436,12754,1115,'559c603a244b4fd326f25bc8fb3b49d88428fdc28a3ec4b9fae5b6e2129ab9d5','8926a350f122d4d565de754fba6622610ee3646431d792dbafa0b2e262c7208d'),
      ('b1-ch-34','chapter',34,35,'Chapter Thirty-Four','The Account That Could Start Another War',12755,13169,1542,'38e4c14144b3d5dfe90c7502e2f1169e2b17935adc3fb035901f516f57ca1c3a','068783d1c86f3956aec7d4568de9f93bbcbb3ffee168c46234a03a04cee1dee5'),
      ('b1-ch-35','chapter',35,36,'Chapter Thirty-Five','The Price of Mercy',13170,13466,987,'34344f58afafb85efe10b3fc7aba6efafbf0c23891824a953df62112bd5a5dbf','b133e1601afb38c5b32836fb8e477288581af08e95703c566da774338ac667e2'),
      ('b1-ch-36','chapter',36,37,'Chapter Thirty-Six','Perrin Leaves Whitehart',13467,13841,2585,'7c7b9e9d0c719cc36867c46cf305ed1ff25a0e31889852cd280315db5ad1e947','aa472e0675ef1d72793e58b43dd2ff364ed08a0d36498fb594d8dea1c2de2e69'),
      ('b1-ch-37','chapter',37,38,'Chapter Thirty-Seven','Nine Days',13842,14078,1998,'44f1759a7597b08298ad6b961be6073703018441d116e3af867805e8292c3170','a4505947bf149af60190a1c988928a30f73212d4d00b6a15a80b4cf44928847b'),
      ('b1-ch-38','chapter',38,39,'Chapter Thirty-Eight','The Lawful Thing',14079,14579,3410,'296d36796e477d6f8f251ce81bcf414b2be5f871c8e67e892a88937802e9f938','b83a03715f8281d5b870ff23799968271f2ac6ab77c4b5f5cf4ddf2d2c844d76'),
      ('b1-ch-39','chapter',39,40,'Chapter Thirty-Nine','Unless You Stop It',14580,14765,982,'728933cbea71921435ab4bc3217cdc47b6184a8364ffb90dfd4caa1c4282fa7a','6a0ddd133ca1ed807a8639365171b318c719072b2cf638482138ba6c11cc0096'),
      ('b1-ch-40','chapter',40,41,'Chapter Forty','Five Days',14766,14902,1346,'e1629de176c6891e0d61d8a747faf31da747bc690c14134a9b89557e19d7e488','b975df3d64377314ff75341ffb7d78753eed6a05afa9047e66cbb947a6959c79'),
      ('b1-ch-41','chapter',41,42,'Chapter Forty-One','The Gate',14903,15103,1656,'9859377ac7fb91fab9765c88fd242a183c78580738b1b3468ad1ae4c2b70c999','a8572b9fd7998e09017f72039172ca1609a0ca223194eef49e20e2d7a3e45946'),
      ('b1-ch-42','chapter',42,43,'Chapter Forty-Two','The Washing',15104,15398,1225,'4d9e8fb636f76913d77ca7d1a8ca29cd886ddce4c28a983a2bc5ddcafa6bb9e8','e9622555ebe928dd345a02a650c3b363c5e2416807faaca0945aa18fe371a670'),
      ('b1-ch-43','chapter',43,44,'Chapter Forty-Three','The Keeper',15399,16040,4645,'508c573ed70656e7d4c38ca5c0145c02c82dcc43390d9ed7129ba827faee325a','286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b'),
      ('b1-ch-44','chapter',44,45,'Chapter Forty-Four','The Divided Report',16041,16273,2109,'e5ef18dfcee757f9150e711ad7e2731e04a9956fa9a1056844d0e30902fea1bc','f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2'),
      ('b1-ch-45','chapter',45,46,'Chapter Forty-Five','That''s How You Know',16274,16692,3003,'f36efcd4a12e5d3cf81b373ec2e258461e1bc8b6af91da7bdaf0fb18532f9cc9','3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07'),
      ('b1-ch-46','chapter',46,47,'Chapter Forty-Six','The Blank Page',16693,17235,2379,'67a1ccf8c8fb3cd58d6d287413749203e4bf00a742d2701e45a20f9a7c4c7189','f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f'),
      ('b1-ch-47','chapter',47,48,'Chapter Forty-Seven','East',17236,17533,2887,'3dbe6690abe1cff3dfb582f0a83dbb9f77b4ffc2f16471d94d8e826fcb1ae761','712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab')
    ) as x(stable_key,section_type,chapter_number,ordinal,label,heading,start_line,end_line,word_count,content_sha256,body_sha256)
  loop
    if r.section_type='interlude' then
      select id into v_scene from public.lore_scenes where book_code='book-1' and title='The Question in the Margin' limit 1;
    else
      select id into v_scene from public.lore_scenes where book_code='book-1' and chapter_number=r.chapter_number and scene_order=1 limit 1;
    end if;

    insert into public.manuscript_sections(book_code,stable_key,section_type,lore_scene_id,notes)
    values ('book-1',r.stable_key,r.section_type,v_scene,'Stable section identity established from v1.6 baseline.')
    on conflict (book_code,stable_key) do update set section_type=excluded.section_type, lore_scene_id=coalesce(public.manuscript_sections.lore_scene_id,excluded.lore_scene_id), updated_at=now()
    returning id into v_section;

    insert into public.manuscript_section_snapshots(manuscript_version_id,section_id,ordinal,chapter_number,label,heading,content_sha256,body_sha256,word_count,start_line,end_line)
    values (v_version,v_section,r.ordinal,r.chapter_number,r.label,r.heading,r.content_sha256,r.body_sha256,r.word_count,r.start_line,r.end_line)
    on conflict (manuscript_version_id,section_id) do update set ordinal=excluded.ordinal,chapter_number=excluded.chapter_number,label=excluded.label,
      heading=excluded.heading,content_sha256=excluded.content_sha256,body_sha256=excluded.body_sha256,word_count=excluded.word_count,start_line=excluded.start_line,end_line=excluded.end_line;
  end loop;
end $$;
