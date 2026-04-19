(() => {
    const EMOJIS = [];
    const EMOJI_RE = /\p{Emoji_Presentation}/u;
    const EMOJI_RANGES = [
      [0x1F300, 0x1F320], [0x1F32D, 0x1F335], [0x1F337, 0x1F37C],
      [0x1F37E, 0x1F393], [0x1F3A0, 0x1F3CA], [0x1F400, 0x1F43E],
      [0x1F442, 0x1F4FC], [0x1F550, 0x1F567], [0x1F5FB, 0x1F64F],
      [0x1F680, 0x1F6C5], [0x1F6F4, 0x1F6FA], [0x1F90D, 0x1F93A],
      [0x1F947, 0x1F971], [0x1F973, 0x1F976], [0x1F97A, 0x1F9A2],
      [0x1F9A5, 0x1F9AA], [0x1F9B4, 0x1F9CA], [0x1F9CD, 0x1F9FF]
    ];
    for (const [start, end] of EMOJI_RANGES) {
      for (let cp = start; cp <= end; cp++) {
        const ch = String.fromCodePoint(cp);
        if (EMOJI_RE.test(ch)) EMOJIS.push(ch);
      }
    }
  
    let last = -1, el = null, emojiEl = null;
    const pick = () => {
      const n = EMOJIS.length;
      if (!n) return "👋";
      if (n === 1) return EMOJIS[0];
      if (last < 0) return EMOJIS[last = (Math.random() * n) | 0];
      let i = (Math.random() * (n - 1)) | 0;
      if (i >= last) i++;
      last = i;
      return EMOJIS[i];
    };
  
    const OVERVIEW_RE = /^(?:\S+\s+)?(?:概览|概覽|Overview)$/i;
    const getTitle = e => (e.textContent || "").trim().replace(/^\S+\s+/, "");
  
    const find = () => {
      for (const e of document.querySelectorAll("main *")) {
        if (OVERVIEW_RE.test((e.textContent || "").trim())) return e;
      }
      return null;
    };
  
    const mount = () => {
      if (!el || !document.contains(el)) el = find();
      if (!el) return false;
  
      if (!emojiEl || !document.contains(emojiEl) || emojiEl.parentNode !== el) {
        const icon = document.createElement("span");
        icon.className = "nezha-overview-emoji";
        icon.textContent = pick();
  
        const text = document.createElement("span");
        text.textContent = getTitle(el);
  
        el.replaceChildren(icon, document.createTextNode(" "), text);
        emojiEl = icon;
      }
      return true;
    };
  
    const update = () => {
      if (document.hidden || !mount()) return;
  
      const next = pick();
      emojiEl.classList.remove("swap");
      void emojiEl.offsetWidth;
      setTimeout(() => { emojiEl.textContent = next; }, 250);
      emojiEl.classList.add("swap");
    };
  
    const boot = setInterval(() => {
      if (mount()) {
        clearInterval(boot);
        setInterval(update, 1500);
      }
    }, 500);
  })();
  