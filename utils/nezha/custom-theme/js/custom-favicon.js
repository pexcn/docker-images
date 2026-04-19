(() => {
  const faviconValue = window.CustomFavicon || window.CustomLogo;
  if (!faviconValue) return;

  const isUrlLike = (value) =>
    typeof value === "string" && /^(https?:|data:|\/)/i.test(value);

  const splitEmojiList = (value) => {
    if (typeof value !== "string") return [];

    if (typeof Intl !== "undefined" && Intl.Segmenter) {
      return [...new Intl.Segmenter(undefined, { granularity: "grapheme" }).segment(value)]
        .map((item) => item.segment)
        .filter((item) => item.trim());
    }

    return Array.from(value).filter((item) => item.trim());
  };

  const pickedFaviconValue = isUrlLike(faviconValue)
    ? faviconValue
    : (() => {
        const list = splitEmojiList(faviconValue);
        return list.length ? list[(Math.random() * list.length) | 0] : faviconValue;
      })();

  const getFaviconType = (url) => {
    const clean = String(url).split("?")[0].split("#")[0].toLowerCase();
    if (clean.endsWith(".ico")) return "image/x-icon";
    if (clean.endsWith(".png")) return "image/png";
    if (clean.endsWith(".svg")) return "image/svg+xml";
    return "";
  };

  const emojiToDataUrl = (emoji) =>
    "data:image/svg+xml," +
    encodeURIComponent(
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <text x="50%" y="50%" text-anchor="middle" dominant-baseline="central" font-size="90">${emoji}</text>
      </svg>`
    );

  const applyFavicon = () => {
    const faviconUrl = isUrlLike(pickedFaviconValue) ? pickedFaviconValue : emojiToDataUrl(pickedFaviconValue);
    const type = isUrlLike(pickedFaviconValue) ? getFaviconType(pickedFaviconValue) : "image/svg+xml";

    document.head
      .querySelectorAll('link[rel="icon"], link[rel="shortcut icon"]')
      .forEach((link) => link.remove());

    for (const rel of ["icon", "shortcut icon", "apple-touch-icon"]) {
      const link = document.createElement("link");
      link.rel = rel;
      if (type) link.type = type;
      link.href = faviconUrl;
      if (!isUrlLike(pickedFaviconValue)) link.sizes = "any";
      document.head.appendChild(link);
    }
  };

  setTimeout(applyFavicon, 50);
  setTimeout(applyFavicon, 500);
})();
