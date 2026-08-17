/* AUREFOLD — "Which of the Ten Houses would you follow?" A shareable quiz.
   Uses only the public house philosophies (locked canon; no spoilers).
   Localized: the interface, questions, philosophies, and taglines follow
   <html lang>. House KEYS and the canonical "House X" names never change
   (they drive share URLs, house-<key>.html, and analytics), so results and
   share links stay identical across languages. */
(function () {
  "use strict";
  var root = document.getElementById("quiz");
  if (!root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);

  // Stable house identity: key + canonical display name (kept in English as a
  // proper noun, matching the rest of the site). Localized philosophy label and
  // tagline are looked up per language below.
  var HOUSES = {
    blackthorn:  { name: "House Blackthorn" },
    ravenshade:  { name: "House Ravenshade" },
    ashbourne:   { name: "House Ashbourne" },
    whitehart:   { name: "House Whitehart" },
    stormrider:  { name: "House Stormrider" },
    ironvale:    { name: "House Ironvale" },
    blackcrest:  { name: "House Blackcrest" },
    stonebear:   { name: "House Stonebear" },
    tidebreaker: { name: "House Tidebreaker" },
    phoenix:     { name: "House Phoenix" }
  };

  var STR = {
    en: {
      phil: {
        blackthorn: "Intellect", ravenshade: "Information", ashbourne: "Courage",
        whitehart: "Faith", stormrider: "Unity", ironvale: "Innovation",
        blackcrest: "the victor's history", stonebear: "Honor",
        tidebreaker: "Knowledge", phoenix: "the future"
      },
      line: {
        blackthorn:  "They plan for every future — and act a moment too late.",
        ravenshade:  "They trade in what people would rather keep hidden.",
        ashbourne:   "They ride at the thing everyone else flinches from.",
        whitehart:   "They listen for a voice — and test those who claim to hear it.",
        stormrider:  "They hold people together — as long as the one who binds them lives.",
        ironvale:    "They measure everything, and build what no one else dares.",
        blackcrest:  "They keep the record — and the record is a kind of power.",
        stonebear:   "They keep their word past the point it costs them everything.",
        tidebreaker: "They chart all of it, and share almost none.",
        phoenix:     "They build on scorched ground and refuse to look down."
      },
      q: [
        { q: "A hard decision looms. What do you trust most?", a: [
          ["A careful plan for every outcome.", "blackthorn"],
          ["What I can find out that others can't.", "ravenshade"],
          ["My own nerve.", "ashbourne"],
          ["What I believe to be true.", "whitehart"] ] },
        { q: "The realm is fracturing. Your first instinct is to—", a: [
          ["Hold everyone together.", "stormrider"],
          ["Build something new from the pieces.", "ironvale"],
          ["Make sure the true account survives.", "blackcrest"],
          ["Keep the oath I swore, whatever it costs.", "stonebear"] ] },
        { q: "People would say your greatest strength is—", a: [
          ["I understand more than I let on.", "tidebreaker"],
          ["I never give up on tomorrow.", "phoenix"],
          ["I think three moves ahead.", "blackthorn"],
          ["I'm simply not afraid.", "ashbourne"] ] },
        { q: "A stranger asks for your help. You—", a: [
          ["Weigh what it will cost me first.", "blackthorn"],
          ["Ask what they're not telling me.", "ravenshade"],
          ["Help — and keep my word on it.", "stonebear"],
          ["Trust the impulse to do right.", "whitehart"] ] },
        { q: "Which sounds most like you?", a: [
          ["Knowledge is worth more than gold.", "tidebreaker"],
          ["Unity is worth more than being right.", "stormrider"],
          ["The story we tell becomes the truth.", "blackcrest"],
          ["The future is worth any fire.", "phoenix"] ] },
        { q: "When everything goes wrong, you—", a: [
          ["Rebuild, better than before.", "phoenix"],
          ["Charge the problem head-on.", "ashbourne"],
          ["Find the fact everyone missed.", "ravenshade"],
          ["Stand by what I promised.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Question " + i + " of " + total; },
        back: "← Back",
        eyebrow: "YOU WOULD FOLLOW",
        castVote: "Cast this as your vote in The Moot",
        listLine: "Curious where House {name}'s story goes? I'll let you know — once, when it's real.",
        aboutHouse: "Read about your house",
        followFree: "Follow free",
        joinReaders: function (n) { return "Join " + n + " reader" + (n === 1 ? "" : "s") + " following along"; },
        shareLabel: "Tell them which house you'd follow",
        shareX: "Share on X", facebook: "Facebook", reddit: "Reddit", copy: "Copy",
        again: "↻ Take it again",
        note: "The book's canon and central mysteries are the author's; the Moot and this quiz shape the world around it — what the archive opens or explores next — never the story's heart.",
        shareText: function (shortName) { return "I'm House " + shortName + " in Aurefold — which house are you?"; }
      }
    },
    sv: {
      phil: {
        blackthorn: "Intellekt", ravenshade: "Information", ashbourne: "Mod",
        whitehart: "Tro", stormrider: "Enhet", ironvale: "Innovation",
        blackcrest: "segrarens historia", stonebear: "Heder",
        tidebreaker: "Kunskap", phoenix: "framtiden"
      },
      line: {
        blackthorn:  "De planerar för varje framtid — och handlar ett ögonblick för sent.",
        ravenshade:  "De handlar med det folk helst vill dölja.",
        ashbourne:   "De rider rakt mot det alla andra ryggar för.",
        whitehart:   "De lyssnar efter en röst — och prövar dem som säger sig höra den.",
        stormrider:  "De håller samman folk — så länge den som binder dem lever.",
        ironvale:    "De mäter allt, och bygger det ingen annan vågar.",
        blackcrest:  "De för handlingen — och handlingen är ett slags makt.",
        stonebear:   "De håller sitt ord bortom den punkt där det kostar dem allt.",
        tidebreaker: "De kartlägger allt, och delar nästan inget.",
        phoenix:     "De bygger på bränd mark och vägrar se ner."
      },
      q: [
        { q: "Ett svårt beslut hotar. Vad litar du mest på?", a: [
          ["En noggrann plan för varje utfall.", "blackthorn"],
          ["Det jag kan ta reda på som andra inte kan.", "ravenshade"],
          ["Mitt eget mod.", "ashbourne"],
          ["Det jag tror är sant.", "whitehart"] ] },
        { q: "Riket splittras. Din första ingivelse är att—", a: [
          ["Hålla alla samman.", "stormrider"],
          ["Bygga något nytt av spillrorna.", "ironvale"],
          ["Se till att den sanna berättelsen överlever.", "blackcrest"],
          ["Hålla eden jag svor, vad det än kostar.", "stonebear"] ] },
        { q: "Folk skulle säga att din största styrka är—", a: [
          ["Jag förstår mer än jag visar.", "tidebreaker"],
          ["Jag ger aldrig upp morgondagen.", "phoenix"],
          ["Jag tänker tre drag framåt.", "blackthorn"],
          ["Jag är helt enkelt inte rädd.", "ashbourne"] ] },
        { q: "En främling ber om din hjälp. Du—", a: [
          ["Väger först vad det kommer att kosta mig.", "blackthorn"],
          ["Frågar vad de inte berättar.", "ravenshade"],
          ["Hjälper — och håller mitt ord om det.", "stonebear"],
          ["Litar på impulsen att göra rätt.", "whitehart"] ] },
        { q: "Vad låter mest som du?", a: [
          ["Kunskap är värd mer än guld.", "tidebreaker"],
          ["Enhet är värd mer än att ha rätt.", "stormrider"],
          ["Berättelsen vi berättar blir sanningen.", "blackcrest"],
          ["Framtiden är värd vilken eld som helst.", "phoenix"] ] },
        { q: "När allt går fel, du—", a: [
          ["Bygger upp igen, bättre än förr.", "phoenix"],
          ["Går rakt på problemet.", "ashbourne"],
          ["Hittar faktumet alla missade.", "ravenshade"],
          ["Står fast vid det jag lovade.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Fråga " + i + " av " + total; },
        back: "← Tillbaka",
        eyebrow: "DU SKULLE FÖLJA",
        castVote: "Lägg detta som din röst i Tinget",
        listLine: "Nyfiken på vart hus {name}s berättelse tar vägen? Jag hör av mig — en gång, när det är på riktigt.",
        aboutHouse: "Läs om ditt hus",
        followFree: "Följ gratis",
        joinReaders: function (n) { return "Gå med " + n + " läsare som följer med"; },
        shareLabel: "Berätta vilket hus du skulle följa",
        shareX: "Dela på X", facebook: "Facebook", reddit: "Reddit", copy: "Kopiera",
        again: "↻ Gör om",
        note: "Bokens kanon och centrala mysterier är författarens; Tinget och det här testet formar världen kring den — vad arkivet öppnar eller utforskar härnäst — aldrig berättelsens hjärta.",
        shareText: function (shortName) { return "Jag skulle följa House " + shortName + " i Aurefold — vilket hus skulle du följa?"; }
      }
    },
    es: {
      phil: {
        blackthorn: "Intelecto", ravenshade: "Información", ashbourne: "Coraje",
        whitehart: "Fe", stormrider: "Unidad", ironvale: "Innovación",
        blackcrest: "la historia del vencedor", stonebear: "Honor",
        tidebreaker: "Conocimiento", phoenix: "el futuro"
      },
      line: {
        blackthorn:  "Planean para cada futuro — y actúan un instante demasiado tarde.",
        ravenshade:  "Comercian con lo que la gente preferiría mantener oculto.",
        ashbourne:   "Cargan contra aquello de lo que todos los demás se apartan.",
        whitehart:   "Escuchan una voz — y ponen a prueba a quienes dicen oírla.",
        stormrider:  "Mantienen unida a la gente — mientras viva quien la une.",
        ironvale:    "Lo miden todo, y construyen lo que nadie más se atreve.",
        blackcrest:  "Guardan el registro — y el registro es una forma de poder.",
        stonebear:   "Mantienen su palabra más allá del punto en que les cuesta todo.",
        tidebreaker: "Lo cartografían todo, y comparten casi nada.",
        phoenix:     "Construyen sobre tierra quemada y se niegan a mirar abajo."
      },
      q: [
        { q: "Se avecina una decisión difícil. ¿En qué confías más?", a: [
          ["Un plan cuidadoso para cada desenlace.", "blackthorn"],
          ["En lo que puedo averiguar y otros no.", "ravenshade"],
          ["En mi propio temple.", "ashbourne"],
          ["En lo que creo que es verdad.", "whitehart"] ] },
        { q: "El reino se fractura. Tu primer instinto es—", a: [
          ["Mantener a todos unidos.", "stormrider"],
          ["Construir algo nuevo con los pedazos.", "ironvale"],
          ["Asegurar que el relato verdadero sobreviva.", "blackcrest"],
          ["Cumplir el juramento que hice, cueste lo que cueste.", "stonebear"] ] },
        { q: "La gente diría que tu mayor fortaleza es—", a: [
          ["Entiendo más de lo que aparento.", "tidebreaker"],
          ["Nunca renuncio al mañana.", "phoenix"],
          ["Pienso tres jugadas por delante.", "blackthorn"],
          ["Sencillamente no tengo miedo.", "ashbourne"] ] },
        { q: "Un desconocido te pide ayuda. Tú—", a: [
          ["Sopeso primero lo que me costará.", "blackthorn"],
          ["Pregunto qué es lo que no me cuentan.", "ravenshade"],
          ["Ayudo — y mantengo mi palabra.", "stonebear"],
          ["Confío en el impulso de hacer el bien.", "whitehart"] ] },
        { q: "¿Qué se parece más a ti?", a: [
          ["El conocimiento vale más que el oro.", "tidebreaker"],
          ["La unidad vale más que tener razón.", "stormrider"],
          ["La historia que contamos se vuelve la verdad.", "blackcrest"],
          ["El futuro vale cualquier fuego.", "phoenix"] ] },
        { q: "Cuando todo sale mal, tú—", a: [
          ["Reconstruyo, mejor que antes.", "phoenix"],
          ["Voy de frente contra el problema.", "ashbourne"],
          ["Encuentro el dato que todos pasaron por alto.", "ravenshade"],
          ["Me mantengo fiel a lo que prometí.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Pregunta " + i + " de " + total; },
        back: "← Atrás",
        eyebrow: "SEGUIRÍAS A",
        castVote: "Lleva esto como tu voto en El Cónclave",
        listLine: "¿Curiosidad por saber adónde va la historia de la Casa {name}? Te avisaré — una vez, cuando sea real.",
        aboutHouse: "Lee sobre tu casa",
        followFree: "Sigue gratis",
        joinReaders: function (n) { return "Únete a " + n + " lector" + (n === 1 ? "" : "es") + " que siguen el proyecto"; },
        shareLabel: "Diles a qué casa seguirías",
        shareX: "Compartir en X", facebook: "Facebook", reddit: "Reddit", copy: "Copiar",
        again: "↻ Volver a hacerlo",
        note: "El canon del libro y sus misterios centrales son del autor; El Cónclave y este test dan forma al mundo que rodea al libro — lo que el archivo abre o explora a continuación — nunca el corazón de la historia.",
        shareText: function (shortName) { return "Seguiría a House " + shortName + " en Aurefold — ¿a qué casa seguirías tú?"; }
      }
    },
    fr: {
      phil: {
        blackthorn: "Intellect", ravenshade: "Information", ashbourne: "Courage",
        whitehart: "Foi", stormrider: "Unité", ironvale: "Innovation",
        blackcrest: "l’histoire du vainqueur", stonebear: "Honneur",
        tidebreaker: "Savoir", phoenix: "l’avenir"
      },
      line: {
        blackthorn:  "Ils planifient chaque avenir — et agissent un instant trop tard.",
        ravenshade:  "Ils font commerce de ce que les gens préféreraient cacher.",
        ashbourne:   "Ils foncent sur ce devant quoi tous les autres reculent.",
        whitehart:   "Ils écoutent une voix — et éprouvent ceux qui prétendent l’entendre.",
        stormrider:  "Ils tiennent les gens ensemble — tant que vit celui qui les lie.",
        ironvale:    "Ils mesurent tout, et bâtissent ce que nul autre n’ose.",
        blackcrest:  "Ils tiennent le registre — et le registre est une forme de pouvoir.",
        stonebear:   "Ils tiennent parole au-delà du point où elle leur coûte tout.",
        tidebreaker: "Ils cartographient tout, et n’en partagent presque rien.",
        phoenix:     "Ils bâtissent sur la terre brûlée et refusent de regarder en bas."
      },
      q: [
        { q: "Une décision difficile approche. À quoi vous fiez-vous le plus ?", a: [
          ["Un plan soigneux pour chaque issue.", "blackthorn"],
          ["À ce que je peux découvrir et que d’autres ne peuvent pas.", "ravenshade"],
          ["À mon propre sang-froid.", "ashbourne"],
          ["À ce que je crois vrai.", "whitehart"] ] },
        { q: "Le royaume se fracture. Votre premier réflexe est de—", a: [
          ["Garder tout le monde uni.", "stormrider"],
          ["Bâtir du neuf à partir des morceaux.", "ironvale"],
          ["Faire en sorte que le récit véridique survive.", "blackcrest"],
          ["Tenir le serment que j’ai prêté, quoi qu’il en coûte.", "stonebear"] ] },
        { q: "On dirait que votre plus grande force est—", a: [
          ["Je comprends plus que je ne le montre.", "tidebreaker"],
          ["Je ne renonce jamais à demain.", "phoenix"],
          ["Je pense trois coups à l’avance.", "blackthorn"],
          ["Je n’ai tout simplement pas peur.", "ashbourne"] ] },
        { q: "Un inconnu vous demande de l’aide. Vous—", a: [
          ["Je pèse d’abord ce que cela va me coûter.", "blackthorn"],
          ["Je demande ce qu’on ne me dit pas.", "ravenshade"],
          ["J’aide — et je tiens parole.", "stonebear"],
          ["Je me fie à l’élan de bien faire.", "whitehart"] ] },
        { q: "Qu’est-ce qui vous ressemble le plus ?", a: [
          ["Le savoir vaut plus que l’or.", "tidebreaker"],
          ["L’unité vaut plus qu’avoir raison.", "stormrider"],
          ["L’histoire que nous racontons devient la vérité.", "blackcrest"],
          ["L’avenir vaut n’importe quel feu.", "phoenix"] ] },
        { q: "Quand tout tourne mal, vous—", a: [
          ["Je reconstruis, en mieux qu’avant.", "phoenix"],
          ["Je fonce droit sur le problème.", "ashbourne"],
          ["Je trouve le fait que tous ont manqué.", "ravenshade"],
          ["Je m’en tiens à ce que j’ai promis.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Question " + i + " sur " + total; },
        back: "← Retour",
        eyebrow: "VOUS SUIVRIEZ",
        castVote: "Portez ceci comme votre vote au Conseil",
        listLine: "Curieux de savoir où va l’histoire de la Maison {name} ? Je vous préviendrai — une fois, quand ce sera réel.",
        aboutHouse: "Lisez à propos de votre maison",
        followFree: "Suivre gratuitement",
        joinReaders: function (n) { return "Rejoignez " + n + " lecteur" + (n === 1 ? "" : "s") + " qui suivent le projet"; },
        shareLabel: "Dites-leur quelle maison vous suivriez",
        shareX: "Partager sur X", facebook: "Facebook", reddit: "Reddit", copy: "Copier",
        again: "↻ Recommencer",
        note: "Le canon du livre et ses mystères centraux appartiennent à l’auteur ; le Conseil et ce quiz façonnent le monde autour du livre — ce que l’archive ouvre ou explore ensuite — jamais le cœur de l’histoire.",
        shareText: function (shortName) { return "Je suivrais House " + shortName + " dans Aurefold — quelle maison suivriez-vous ?"; }
      }
    },
    zh: {
      phil: {
        blackthorn: "智识", ravenshade: "情报", ashbourne: "勇气",
        whitehart: "信仰", stormrider: "团结", ironvale: "革新",
        blackcrest: "胜者的历史", stonebear: "荣誉",
        tidebreaker: "知识", phoenix: "未来"
      },
      line: {
        blackthorn:  "他们为每一种未来谋划——却总是慢了一步。",
        ravenshade:  "他们买卖人们宁愿藏起来的东西。",
        ashbourne:   "别人退避的地方，他们偏偏冲上去。",
        whitehart:   "他们聆听一个声音——并考验那些声称听见它的人。",
        stormrider:  "他们把众人聚在一起——只要那个维系他们的人还活着。",
        ironvale:    "他们丈量一切，建造无人敢建之物。",
        blackcrest:  "他们保管记录——而记录本身就是一种权力。",
        stonebear:   "他们信守诺言，哪怕代价是失去一切。",
        tidebreaker: "他们绘尽万物，却几乎从不分享。",
        phoenix:     "他们在焦土上重建，绝不低头。"
      },
      q: [
        { q: "一个艰难的抉择迫在眉睫。你最信任什么？", a: [
          ["为每一种结局周全谋划。", "blackthorn"],
          ["我能查到而别人查不到的东西。", "ravenshade"],
          ["我自己的胆识。", "ashbourne"],
          ["我所相信为真的事。", "whitehart"] ] },
        { q: "王国正在分裂。你的第一反应是——", a: [
          ["把所有人聚拢在一起。", "stormrider"],
          ["用碎片建造新的东西。", "ironvale"],
          ["确保真实的记述留存下来。", "blackcrest"],
          ["信守我立下的誓言，无论代价。", "stonebear"] ] },
        { q: "人们会说你最大的长处是——", a: [
          ["我懂得比表现出来的多。", "tidebreaker"],
          ["我从不放弃明天。", "phoenix"],
          ["我料先三步。", "blackthorn"],
          ["我根本不害怕。", "ashbourne"] ] },
        { q: "一个陌生人向你求助。你——", a: [
          ["先掂量这会让我付出什么。", "blackthorn"],
          ["追问他们没说出口的事。", "ravenshade"],
          ["伸手相助——并信守承诺。", "stonebear"],
          ["凭着行善的冲动去做。", "whitehart"] ] },
        { q: "哪一句最像你？", a: [
          ["知识胜过黄金。", "tidebreaker"],
          ["团结胜过争对错。", "stormrider"],
          ["我们讲述的故事会成为真相。", "blackcrest"],
          ["未来值得任何一场火。", "phoenix"] ] },
        { q: "当一切出错时，你——", a: [
          ["重建，比从前更好。", "phoenix"],
          ["正面迎向问题。", "ashbourne"],
          ["找出所有人都忽略的事实。", "ravenshade"],
          ["坚守我承诺过的事。", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "第 " + i + " 题，共 " + total + " 题"; },
        back: "← 返回",
        eyebrow: "你会追随",
        castVote: "把它作为你在议会的一票",
        listLine: "想知道{name}家族的故事走向何方？有真正的消息时，我会告诉你——只此一次。",
        aboutHouse: "阅读关于你的家族",
        followFree: "免费关注",
        joinReaders: function (n) { return "加入 " + n + " 位持续关注的读者"; },
        shareLabel: "告诉他们你会追随哪个家族",
        shareX: "分享到 X", facebook: "Facebook", reddit: "Reddit", copy: "复制",
        again: "↻ 再测一次",
        note: "本书的正典与核心谜团属于作者；议会与本测验塑造的是书本周围的世界——档案接下来揭示或探索什么——而绝非故事的核心。",
        shareText: function (shortName) { return "在 Aurefold 中我会追随 House " + shortName + "——你会追随哪个家族？"; }
      }
    },
    ja: {
      phil: {
        blackthorn: "知性", ravenshade: "情報", ashbourne: "勇気",
        whitehart: "信仰", stormrider: "結束", ironvale: "革新",
        blackcrest: "勝者の歴史", stonebear: "名誉",
        tidebreaker: "知識", phoenix: "未来"
      },
      line: {
        blackthorn:  "彼らはあらゆる未来に備える——そして一瞬、遅れて動く。",
        ravenshade:  "彼らは人が隠しておきたいものを商う。",
        ashbourne:   "誰もがひるむものへ、彼らは突き進む。",
        whitehart:   "彼らは一つの声に耳を澄ます——そしてそれを聞いたと言う者を試す。",
        stormrider:  "彼らは人々をまとめる——束ねる者が生きている限り。",
        ironvale:    "彼らはすべてを測り、誰も敢えて造らぬものを築く。",
        blackcrest:  "彼らは記録を守る——そして記録は一種の力である。",
        stonebear:   "彼らはすべてを失う一線を越えても、約束を守る。",
        tidebreaker: "彼らはすべてを図に描き、ほとんど何も分かち合わない。",
        phoenix:     "彼らは焼けた土の上に築き、決して下を見ない。"
      },
      q: [
        { q: "難しい決断が迫っている。あなたが最も信じるものは？", a: [
          ["あらゆる結末に備えた綿密な計画。", "blackthorn"],
          ["他人には得られない、私が突き止められること。", "ravenshade"],
          ["自分自身の胆力。", "ashbourne"],
          ["自分が真実だと信じること。", "whitehart"] ] },
        { q: "王国が割れつつある。あなたの最初の衝動は——", a: [
          ["皆をまとめること。", "stormrider"],
          ["破片から新しいものを築くこと。", "ironvale"],
          ["真実の記録を残すこと。", "blackcrest"],
          ["立てた誓いを、代償を問わず守ること。", "stonebear"] ] },
        { q: "人はあなたの最大の強みをこう言うだろう——", a: [
          ["私は見せる以上に理解している。", "tidebreaker"],
          ["私は決して明日を諦めない。", "phoenix"],
          ["私は三手先を読む。", "blackthorn"],
          ["私はただ恐れを知らない。", "ashbourne"] ] },
        { q: "見知らぬ人が助けを求めてくる。あなたは——", a: [
          ["まず自分の払う代償を量る。", "blackthorn"],
          ["語られていないことを問う。", "ravenshade"],
          ["手を貸す——そして約束を守る。", "stonebear"],
          ["善を為そうとする衝動を信じる。", "whitehart"] ] },
        { q: "最もあなたらしいのは？", a: [
          ["知識は黄金に勝る。", "tidebreaker"],
          ["結束は正しさに勝る。", "stormrider"],
          ["私たちが語る物語が真実になる。", "blackcrest"],
          ["未来はどんな炎にも値する。", "phoenix"] ] },
        { q: "すべてがうまくいかないとき、あなたは——", a: [
          ["以前より良く、築き直す。", "phoenix"],
          ["問題に正面から突っ込む。", "ashbourne"],
          ["誰もが見落とした事実を見つける。", "ravenshade"],
          ["約束したことを守り抜く。", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return total + "問中 " + i + "問目"; },
        back: "← 戻る",
        eyebrow: "あなたが従うのは",
        castVote: "これを合議での一票とする",
        listLine: "{name}家の物語がどこへ向かうのか気になりますか。本当に動いたとき、一度だけお知らせします。",
        aboutHouse: "あなたの家門について読む",
        followFree: "無料でフォロー",
        joinReaders: function (n) { return n + "人の読者とともに追いかける"; },
        shareLabel: "どの家に従うか教えよう",
        shareX: "X でシェア", facebook: "Facebook", reddit: "Reddit", copy: "コピー",
        again: "↻ もう一度",
        note: "本の正典と中心的な謎は作者のもの。合議とこの診断が形づくるのは本を取り巻く世界——記録が次に何を開き、探るか——であって、物語の核心では決してない。",
        shareText: function (shortName) { return "Aurefold で私は House " + shortName + " に従う——あなたはどの家に従う？"; }
      }
    }
  };

  var T = STR[LANG] || STR.en;
  var UI = T.ui;
  var Q = T.q;
  var answers = [];

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function leadingHouse() {
    var tally = {}, best = null, bestN = -1;
    answers.forEach(function (h) {
      tally[h] = (tally[h] || 0) + 1;
      if (tally[h] > bestN) { bestN = tally[h]; best = h; }
    });
    return best;
  }

  function render(i) {
    root.innerHTML = "";
    var total = Q.length;
    var prog = el("p", "quiz-progress", UI.progress(i + 1, total));
    root.appendChild(prog);
    var bar = el("div", "quiz-bar");
    var fill = el("div", "quiz-bar-fill");
    fill.style.width = Math.round((i / total) * 100) + "%";
    bar.appendChild(fill); root.appendChild(bar);

    // The leading house tints the progress accents (--hc); decorative rule
    // sits in normal flow so it can never harm text contrast.
    root.style.setProperty("--hc", answers.length ? "var(--house-" + leadingHouse() + ")" : "");
    var rule = el("div", "quiz-rule");
    rule.setAttribute("aria-hidden", "true");
    rule.appendChild(el("span", "quiz-rule-mark"));
    root.appendChild(rule);

    root.appendChild(el("h2", "quiz-question", Q[i].q));
    var list = el("div", "quiz-options");
    Q[i].a.forEach(function (opt) {
      var b = el("button", "quiz-option", opt[0]);
      b.type = "button";
      b.addEventListener("click", function () {
        answers[i] = opt[1];
        if (i + 1 < total) render(i + 1); else result();
      });
      list.appendChild(b);
    });
    root.appendChild(list);
    if (i > 0) {
      var back = el("button", "quiz-back", UI.back);
      back.type = "button";
      back.addEventListener("click", function () { render(i - 1); });
      root.appendChild(back);
    }
  }

  function result() {
    var tally = {};
    answers.forEach(function (h) { tally[h] = (tally[h] || 0) + 1; });
    // highest score; ties broken by earliest appearance in answers
    var best = null, bestN = -1;
    answers.forEach(function (h) {
      if (tally[h] > bestN) { bestN = tally[h]; best = h; }
    });
    var house = HOUSES[best];

    root.innerHTML = "";
    var card = el("div", "quiz-result");
    card.style.setProperty("--hc", "var(--house-" + best + ")");
    var sigil = document.createElement("img");
    sigil.className = "result-sigil";
    sigil.src = "assets/sigils/" + best + ".webp";
    sigil.alt = "";
    sigil.onerror = function () { if (this.dataset.f) { this.hidden = true; } else { this.dataset.f = 1; this.src = "assets/sigils/" + best + ".png"; } };
    card.appendChild(sigil);
    card.appendChild(el("p", "quiz-result-eyebrow", UI.eyebrow));
    card.appendChild(el("h2", "quiz-result-house", house.name));
    card.appendChild(el("p", "quiz-result-phil", T.phil[best]));
    card.appendChild(el("p", "quiz-result-line", "“" + T.line[best] + "”"));

    var shortName = house.name.replace(/^House\s+/, "");
    // Share the per-house result page so the link unfurls with that house's card.
    // Language-aware: a share from /sv/ should land the friend on /sv/.
    var pageUrl = "https://aurefold.com/" + (LANG === "en" ? "" : LANG + "/") + "house-" + best + ".html";
    var shareText = UI.shareText(shortName);

    // Primary next steps: carry the result into the Moot, or follow the journey.
    var row = el("div", "cta-row");
    row.style.justifyContent = "center";

    // Pre-fills the matching option in the Moot's house poll (never submits).
    var a1 = el("a", "btn btn-primary", UI.castVote);
    a1.href = "vote.html#house=" + encodeURIComponent(best);

    // The matched house's own page — relative, so /sv/quiz.html stays on /sv/.
    var aAbout = el("a", "btn btn-ghost", UI.aboutHouse);
    aAbout.href = "house-" + best + ".html";

    // "Follow free" uses whatever support link is configured — no hardcoded URL.
    var sup = ((window.AUREFOLD_COMMUNITY || {}).support) || {};
    var followUrl = (sup.patreon && String(sup.patreon).trim()) ? String(sup.patreon).trim() : "support.html";
    var a2 = el("a", "btn btn-ghost", UI.followFree);
    a2.href = followUrl;
    if (/^https?:/i.test(followUrl)) { a2.target = "_blank"; a2.rel = "noopener"; }

    row.appendChild(a1); row.appendChild(aAbout); row.appendChild(a2);
    card.appendChild(row);

    // Quiet owned-list line — the highest-intent moment gets an honest option.
    if (UI.listLine && document.getElementById("reading-list")) {
      var listP = el("p", "world-note");
      var listA = document.createElement("a");
      listA.href = "#reading-list";
      listA.textContent = UI.listLine.replace("{name}", shortName);
      listP.appendChild(listA);
      listP.style.marginTop = "16px";
      card.appendChild(listP);
    }

    // Social proof, if a real member count is configured (hidden otherwise).
    var mem = ((window.AUREFOLD_COMMUNITY || {}).momentum || {}).members;
    if (typeof mem === "number" && mem > 0) {
      card.appendChild(el("p", "social-proof", UI.joinReaders(mem)));
    }

    // Share chips reuse the site-wide .share-row pattern; the Copy chip uses the
    // shared [data-copy] handler in site.js. Nothing shares or copies on its own.
    var shareBlock = el("div", "share-block");
    shareBlock.appendChild(el("p", "share-label", UI.shareLabel));
    var share = el("div", "share-row");
    var enc = encodeURIComponent, t = enc(shareText), u = enc(pageUrl);
    [
      [UI.shareX, "https://twitter.com/intent/tweet?text=" + t + "&url=" + u],
      [UI.facebook, "https://www.facebook.com/sharer/sharer.php?u=" + u],
      [UI.reddit, "https://www.reddit.com/submit?url=" + u + "&title=" + t]
    ].forEach(function (l) {
      var a = el("a", "share-btn", l[0]);
      a.href = l[1]; a.target = "_blank"; a.rel = "noopener";
      share.appendChild(a);
    });
    var copy = el("button", "share-btn", UI.copy);
    copy.type = "button";
    copy.setAttribute("data-copy", shareText + " " + pageUrl);
    share.appendChild(copy);
    shareBlock.appendChild(share);
    card.appendChild(shareBlock);

    var again = el("button", "quiz-back", UI.again);
    again.type = "button";
    again.addEventListener("click", function () { answers = []; render(0); });
    card.appendChild(again);

    card.appendChild(el("p", "quiz-note", UI.note));
    root.appendChild(card);

    if (window.plausible) window.plausible("Quiz result", { props: { house: house.name } });
  }

  render(0);
})();
