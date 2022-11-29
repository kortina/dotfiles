// javascript:
(function () {
  window.uMatches = (nodeName, pattern) => {
    return Array.from(document.getElementsByTagName(nodeName)).filter(
      (e) => e.innerText && e.innerText.match(pattern)
    );
  };
  window.uNodes = Array.from(document.getElementsByTagName('span')).filter(
    (e) => e.getAttribute('role') == 'link' && e.innerText == 'Unsubscribe'
  );
  if (window.uNodes.length) {
    uNodes.map((e) => {
      e.click();
      setTimeout(() => {
        window.uMatches('button', /^Unsubscribe$/).map((e) => e.click());
      }, 100);
    });
  }
  if (!window.uNodes.length) {
    window.uNodes = window.uMatches('a', /unsub|optout|opt out|opt-out/i);
  }
  if (!window.uNodes.length) {
    window.uNodes = window.uMatches('a', /click here|clickhere/i);
  }
  if (!window.uNodes.length) {
    window.uNodes = window.uMatches('a', /here/i);
  }
  if (window.uNodes.length) {
    window.uNodes.reverse();
    window.uNodes[0].click();
  }
})();
