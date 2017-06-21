var h = {
  a: 1,
  b: 2,
};

var i = {
  b: 3,
  c: 4,
};

var j = { ...h, ...i, c: 5 };

var k = {
  a: 1,
  b: 2,
  b: 3,
  c: 4,
  c: 5,
};
