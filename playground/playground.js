var array = ['jenny', 'andrew'];

var objects = array.map(i => {
  return { name: i };
});

console.log('objects', objects);

// try to capitalize all the names
// and return
// {name: "JENNY"}
// , {name: "ANDREW"}
var capsObjects = objects.map(o => {
  o.name = o.name.toUpperCase();
  return o;
});

console.log('capsObjects', capsObjects);

// BUT...
console.log('objects', objects);

capsObjects = Object.freeze(capsObjects); // even this won't help us not-mutate objects inside the array

var jen = { name: 'jenny' };
Object.freeze(jen);
jen.name = 1;
console.log('jen.name', jen.name); // still jenny

// let's try to make lower objects from capsObjects and leave capsObjects in caps
// toLowerCase()

let lowerObjects = capsObjects.map(o => {
  var name = o.name.toLowerCase();
  return {
    name: name,
    nickname: `${name}star`,
  };
});

// should print:
// [{name: 'jenny'}, {name: 'andrew'}]
console.log('lowerObjects', lowerObjects);

// should print:
// [{name: 'JENNY'}, {name: 'ANDREW'}]
console.log('capsObjects', capsObjects);
