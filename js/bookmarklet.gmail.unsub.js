// javascript:
Array.from(document.getElementsByTagName('span'))
  .filter((e) => e.getAttribute('role') == 'link' && e.innerText == 'Unsubscribe')
  .map((e) => e.click());
setTimeout(() => {
  Array.from(document.getElementsByTagName('button'))
    .filter((e) => e.innerText == 'Unsubscribe')
    .map((e) => e.click());
}, 100);
