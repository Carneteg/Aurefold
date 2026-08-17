/* AUREFOLD — curated character features for the homepage and Book One page.
 * Reads only the public-safe site_character_gallery view and ratified portrait paths.
 */
(function () {
  "use strict";

  const HOME = ["sela", "tomas", "alaine", "fen", "perrin", "wren"];
  const BOOK = ["sela", "tomas", "alaine", "fen", "perrin", "wilda"];

  const COPY = {
    en: {
      home: {
        eyebrow: "THE PEOPLE OF BOOK ONE",
        title: "The people who carry Book One",
        intro: "The Bell of Silence is built on witnesses, keepers, laborers, believers, and people forced to carry meanings they never chose.",
        cta: "Meet all 26 faces",
        lines: {
          sela: "A goatherd pulled into public meaning when the world demands an answer she refuses to invent.",
          tomas: "A Whitehart tester whose devotion to procedure begins to collide with the cost of certainty.",
          alaine: "Stillness, judgment, and authority — the kind that can shelter a people or close around them.",
          fen: "A worker who knows what institutions forget: names, labor, and the grief beneath every ritual claim.",
          perrin: "A chronicler gathering words that may preserve the forgotten — or turn them into history's weapon.",
          wren: "An investigator more loyal to observation than comfort, and therefore dangerous in rooms built on conclusion."
        }
      },
      book: {
        eyebrow: "THE PEOPLE AROUND THE BELL",
        title: "Before the world becomes history, it is lived by them",
        intro: "Every judgment in the valley passes through human hands first: a goatherd, a tester, a keeper of rites, a chronicler, a worker, an authority.",
        cta: "See the full cast",
        lines: {
          sela: "She says only what she knows, and the whole valley suffers for the difference.",
          tomas: "He was trained to test voices, not to live with doubt of his own.",
          alaine: "Authority taught her how to stand still while the world leans on her — and what that stillness can cost.",
          fen: "He knows the labor, the names, and the indignity of being useful without being legible.",
          perrin: "He arrives to record, and in recording changes what can later be remembered.",
          wilda: "She knows how the correct word can remain correct and still wound the person standing beneath it."
        }
      }
    },
    sv: {
      home: {
        eyebrow: "MÄNNISKORNA I BOK ETT", title: "Människorna som bär Bok Ett",
        intro: "The Bell of Silence bärs av vittnen, väktare, arbetare, troende och människor som tvingas bära betydelser de aldrig själva valt.",
        cta: "Möt alla 26 ansikten",
        lines: {
          sela: "En getvallare som dras in i offentlig betydelse när världen kräver ett svar hon vägrar hitta på.",
          tomas: "En Whitehart-prövare vars tro på proceduren börjar kollidera med visshetens pris.",
          alaine: "Stillhet, omdöme och auktoritet — sådan som kan skydda ett folk eller sluta sig kring det.",
          fen: "En arbetare som vet vad institutioner glömmer: namn, arbete och sorgen under varje rituellt anspråk.",
          perrin: "En krönikör som samlar ord som kan bevara de glömda — eller göra dem till historiens vapen.",
          wren: "En utredare mer lojal mot observation än bekvämlighet, och därför farlig i rum byggda på slutsatser."
        }
      },
      book: {
        eyebrow: "MÄNNISKORNA KRING KLOCKAN", title: "Innan världen blir historia levs den av dem",
        intro: "Varje dom i dalen passerar först genom mänskliga händer: en getvallare, en prövare, en ritväktare, en krönikör, en arbetare, en auktoritet.",
        cta: "Se hela rollistan",
        lines: {
          sela: "Hon säger bara det hon vet, och hela dalen får betala för skillnaden.",
          tomas: "Han tränades att pröva röster, inte att leva med sitt eget tvivel.",
          alaine: "Auktoriteten lärde henne stå still medan världen lutar sig mot henne — och vad den stillheten kostar.",
          fen: "Han känner arbetet, namnen och förödmjukelsen i att vara nyttig utan att vara läsbar.",
          perrin: "Han kommer för att nedteckna, och genom att göra det förändrar han vad som senare kan minnas.",
          wilda: "Hon vet hur det rätta ordet kan förbli rätt och ändå såra människan som står under det."
        }
      }
    },
    es: {
      home: {
        eyebrow: "LAS PERSONAS DEL LIBRO UNO", title: "Quienes sostienen el Libro Uno",
        intro: "The Bell of Silence se sostiene sobre testigos, guardianes, trabajadores, creyentes y personas obligadas a cargar significados que nunca eligieron.",
        cta: "Conoce los 26 rostros",
        lines: {
          sela: "Una cabrera convertida en significado público cuando el mundo exige una respuesta que se niega a inventar.",
          tomas: "Un examinador de Whitehart cuya fe en el procedimiento empieza a chocar con el precio de la certeza.",
          alaine: "Quietud, juicio y autoridad: capaces de proteger a un pueblo o de cerrarse sobre él.",
          fen: "Un trabajador que conoce lo que las instituciones olvidan: nombres, trabajo y dolor bajo cada rito.",
          perrin: "Un cronista que reúne palabras capaces de preservar a los olvidados — o convertirlos en arma de la historia.",
          wren: "Una investigadora más leal a la observación que a la comodidad, peligrosa donde las conclusiones ya están hechas."
        }
      },
      book: {
        eyebrow: "LAS PERSONAS ALREDEDOR DE LA CAMPANA", title: "Antes de ser historia, el mundo es vivido por ellos",
        intro: "Cada juicio del valle pasa primero por manos humanas: una cabrera, un examinador, una guardiana del rito, un cronista, un trabajador, una autoridad.",
        cta: "Ver todo el reparto",
        lines: {
          sela: "Dice solo lo que sabe, y todo el valle sufre por esa diferencia.",
          tomas: "Fue entrenado para examinar voces, no para vivir con su propia duda.",
          alaine: "La autoridad le enseñó a permanecer inmóvil mientras el mundo se apoya en ella — y cuánto cuesta esa quietud.",
          fen: "Conoce el trabajo, los nombres y la indignidad de ser útil sin ser legible.",
          perrin: "Llega para registrar, y al hacerlo cambia lo que podrá recordarse después.",
          wilda: "Sabe que la palabra correcta puede seguir siendo correcta y aun así herir a quien queda debajo."
        }
      }
    },
    fr: {
      home: {
        eyebrow: "LES GENS DU LIVRE UN", title: "Ceux qui portent le Livre Un",
        intro: "The Bell of Silence repose sur des témoins, des gardiens, des travailleurs, des croyants et des êtres forcés de porter des significations qu'ils n'ont jamais choisies.",
        cta: "Découvrir les 26 visages",
        lines: {
          sela: "Une chevrière transformée en symbole public lorsque le monde exige une réponse qu'elle refuse d'inventer.",
          tomas: "Un examinateur Whitehart dont la foi dans la procédure se heurte peu à peu au prix de la certitude.",
          alaine: "Immobilité, jugement et autorité — capables d'abriter un peuple ou de se refermer sur lui.",
          fen: "Un travailleur qui sait ce que les institutions oublient : les noms, le labeur et le chagrin sous chaque rite.",
          perrin: "Un chroniqueur qui recueille des mots capables de préserver les oubliés — ou d'en faire l'arme de l'histoire.",
          wren: "Une enquêtrice plus fidèle à l'observation qu'au confort, donc dangereuse dans les pièces bâties sur des conclusions."
        }
      },
      book: {
        eyebrow: "LES GENS AUTOUR DE LA CLOCHE", title: "Avant de devenir histoire, le monde est vécu par eux",
        intro: "Chaque jugement de la vallée passe d'abord par des mains humaines : une chevrière, un examinateur, une gardienne des rites, un chroniqueur, un travailleur, une autorité.",
        cta: "Voir tous les personnages",
        lines: {
          sela: "Elle ne dit que ce qu'elle sait, et toute la vallée souffre de cette différence.",
          tomas: "On l'a formé à éprouver les voix, pas à vivre avec son propre doute.",
          alaine: "L'autorité lui a appris à rester immobile pendant que le monde s'appuie sur elle — et ce que cette immobilité coûte.",
          fen: "Il connaît le travail, les noms et l'indignité d'être utile sans être lisible.",
          perrin: "Il vient consigner, et en consignant change ce qui pourra plus tard être retenu.",
          wilda: "Elle sait que le mot juste peut rester juste tout en blessant celui qui se tient dessous."
        }
      }
    },
    zh: {
      home: {
        eyebrow: "第一部的人物", title: "承载第一部的人",
        intro: "《The Bell of Silence》由证人、守护者、劳动者、信徒，以及那些被迫承受从未选择过的意义的人共同撑起。",
        cta: "认识全部26位人物",
        lines: {
          sela: "一个牧羊女孩；当世界逼她给出答案时，她拒绝编造，于是被塑造成公共意义。",
          tomas: "Whitehart 的审验者，对程序的信仰开始与确定性的代价发生冲突。",
          alaine: "静默、判断与权威——既能庇护一个群体，也能将它紧紧封闭。",
          fen: "一个知道制度会遗忘什么的劳动者：姓名、劳作，以及每种仪式主张之下的悲伤。",
          perrin: "一位收集言辞的编年者；这些文字可以保存被遗忘者，也能成为历史的武器。",
          wren: "一位更忠于观察而非舒适的调查者，因此在结论早已写好的房间里格外危险。"
        }
      },
      book: {
        eyebrow: "钟声周围的人", title: "世界成为历史之前，先由他们活过",
        intro: "山谷中的每一次判断都先经过人的手：牧羊女孩、审验者、仪式守护者、编年者、劳动者与权威者。",
        cta: "查看完整人物阵容",
        lines: {
          sela: "她只说自己知道的，而整个山谷都要承受这种区别。",
          tomas: "他受训审验别人的声音，却没有学会如何与自己的怀疑共处。",
          alaine: "权威教会她在世界倚靠自己时保持不动——也教会她这种静止的代价。",
          fen: "他知道劳作、姓名，以及有用却不被制度看见的屈辱。",
          perrin: "他来记录，而记录本身改变了后来能够被记住的东西。",
          wilda: "她知道正确的词依然可以是正确的，同时伤害站在它之下的人。"
        }
      }
    },
    ja: {
      home: {
        eyebrow: "第一巻の人々", title: "第一巻を背負う人々",
        intro: "『The Bell of Silence』を支えるのは、証人、守り手、働く者、信じる者、そして自ら選んでいない意味を背負わされる人々です。",
        cta: "26人すべてを見る",
        lines: {
          sela: "世界が答えを求めても作り話を拒み、そのため公の意味を背負わされる山羊飼い。",
          tomas: "手続きへの献身が、確実さの代償と衝突し始めるWhitehartの試問官。",
          alaine: "静けさ、判断、権威——人々を守ることも、囲い込むこともできる力。",
          fen: "制度が忘れるものを知る働き手——名前、労働、そして儀式の下にある悲しみ。",
          perrin: "忘れられた者を残すことも、歴史の武器に変えることもできる言葉を集める記録者。",
          wren: "快適さより観察に忠実な調査者。結論で固められた部屋では、それゆえ危険な存在。"
        }
      },
      book: {
        eyebrow: "鐘を囲む人々", title: "世界が歴史になる前に、彼らがそれを生きる",
        intro: "谷のあらゆる判断は、まず人の手を通る——山羊飼い、試問官、儀式の守り手、記録者、働き手、権威者。",
        cta: "登場人物をすべて見る",
        lines: {
          sela: "彼女は知っていることだけを語り、その違いを谷全体が引き受ける。",
          tomas: "声を試す訓練は受けたが、自分自身の疑いと生きる訓練は受けていない。",
          alaine: "権威は、世界が彼女にもたれる間じっと立つ方法と、その静けさの代償を教えた。",
          fen: "彼は労働と名前、そして役に立ちながら制度には読まれない屈辱を知っている。",
          perrin: "彼は記録しに来る。そして記録することで、後に何が記憶され得るかを変えてしまう。",
          wilda: "正しい言葉が正しいままでも、その下に立つ人を傷つけ得ることを知っている。"
        }
      }
    }
  };

  function language() {
    const l = (document.documentElement.lang || "en").toLowerCase().slice(0, 2);
    return COPY[l] ? l : "en";
  }

  function pageKind() {
    const p = location.pathname.replace(/\/+$/, "");
    if (p.endsWith("/book.html") || p === "/book.html") return "book";
    if (p === "" || p === "/" || /^\/(sv|es|fr|zh|ja)$/.test(p) || /\/index\.html$/.test(p)) return "home";
    return null;
  }

  function charactersUrl() {
    const match = location.pathname.match(/^\/(sv|es|fr|zh|ja)(?:\/|$)/);
    return match ? `/${match[1]}/characters.html` : "/characters.html";
  }

  function storageUrl(path, sha) {
    const cfg = window.AUREFOLD_COMMUNITY || {};
    if (!cfg.supabaseUrl || !path) return "";
    const safe = path.split("/").map(encodeURIComponent).join("/");
    return `${cfg.supabaseUrl}/storage/v1/object/public/character-art/${safe}${sha ? `?v=${sha.slice(0, 12)}` : ""}`;
  }

  async function fetchRows(ids) {
    const cfg = window.AUREFOLD_COMMUNITY || {};
    if (!cfg.supabaseUrl || !cfg.supabaseKey) throw new Error("Supabase public config missing");
    const filter = encodeURIComponent(`(${ids.join(",")})`);
    const url = `${cfg.supabaseUrl}/rest/v1/site_character_gallery?select=id,name,portrait_path,portrait_sha256&id=in.${filter}`;
    const response = await fetch(url, {
      headers: { apikey: cfg.supabaseKey, Authorization: `Bearer ${cfg.supabaseKey}`, Accept: "application/json" }
    });
    if (!response.ok) throw new Error(`Character gallery ${response.status}`);
    return response.json();
  }

  function portrait(row, alt, lead) {
    const img = document.createElement("img");
    img.className = lead ? "featured-face-lead-image" : "featured-face-image";
    img.src = storageUrl(row.portrait_path, row.portrait_sha256);
    img.alt = alt;
    img.loading = "lazy";
    img.decoding = "async";
    return img;
  }

  function render(kind, rows) {
    const c = COPY[language()][kind];
    const ids = kind === "home" ? HOME : BOOK;
    const byId = new Map(rows.map((r) => [r.id, r]));
    if (!ids.every((id) => byId.get(id)?.portrait_path)) return;

    const section = document.createElement("section");
    section.className = `featured-faces featured-faces--${kind}`;
    section.setAttribute("aria-labelledby", `featured-faces-${kind}-title`);

    const head = document.createElement("div");
    head.className = "featured-faces-head";
    head.innerHTML = `<p class="featured-faces-eyebrow">${c.eyebrow}</p><h2 id="featured-faces-${kind}-title">${c.title}</h2><p>${c.intro}</p>`;
    section.appendChild(head);

    const leadRow = byId.get("sela");
    const lead = document.createElement("article");
    lead.className = "featured-face-lead";
    lead.appendChild(portrait(leadRow, `${leadRow.name} — Book One`, true));
    const leadCopy = document.createElement("div");
    leadCopy.className = "featured-face-lead-copy";
    leadCopy.innerHTML = `<p class="featured-face-role">BOOK ONE</p><h3>${leadRow.name}</h3><p>${c.lines.sela}</p>`;
    lead.appendChild(leadCopy);
    section.appendChild(lead);

    const grid = document.createElement("div");
    grid.className = "featured-face-support";
    ids.slice(1).forEach((id) => {
      const row = byId.get(id);
      const card = document.createElement("article");
      card.className = "featured-face-card";
      card.appendChild(portrait(row, `${row.name} — Book One`, false));
      const body = document.createElement("div");
      body.className = "featured-face-card-copy";
      body.innerHTML = `<h3>${row.name}</h3><p>${c.lines[id]}</p>`;
      card.appendChild(body);
      grid.appendChild(card);
    });
    section.appendChild(grid);

    const action = document.createElement("p");
    action.className = "featured-faces-action";
    action.innerHTML = `<a href="${charactersUrl()}">${c.cta} <span aria-hidden="true">→</span></a>`;
    section.appendChild(action);

    if (kind === "home") {
      const announcement = document.querySelector("main.page .announcement");
      if (announcement) announcement.insertAdjacentElement("beforebegin", section);
    } else {
      const quote = document.querySelector("main.page .band-quote");
      if (quote) quote.insertAdjacentElement("beforebegin", section);
    }
  }

  async function init() {
    const kind = pageKind();
    if (!kind) return;
    const ids = kind === "home" ? HOME : BOOK;
    try {
      render(kind, await fetchRows(ids));
    } catch (error) {
      console.warn("Aurefold featured faces unavailable; page remains fully usable.", error);
    }
  }

  init();
})();
