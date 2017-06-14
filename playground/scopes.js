#!/usr/bin/env node

/*
See also:

https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let
*/
const globalGuy = 'gary';
var globalValet = 'driver';
const globalObject = { propertyGuy: 'perry' };

(() => {
  // define your function in a closure so you don't overwrite someone else's foo
  const foo = () => {
    console.log('globalGuy in foo', globalGuy);
    console.log('globalValet in foo', globalValet);
    console.log('globalObject.propertyGuy in foo', globalObject.propertyGuy);
    // globalGuy = 'gerald'; // can't do, const
    globalObject.propertyGuy = 'louie'; // set the value of a property on an object
    globalValet = 'speed racer';

    const localGal = 'jenny';
    console.log('localGal in foo', localGal);
  };

  foo();
})();

// foo(); // undefined
console.log('globalGuy at bottom', globalGuy);
console.log('globalValet at bottom', globalValet);
console.log('globalObject.propertyGuy at bottom', globalObject.propertyGuy);
// console.log('localGal at bottom', localGal); // undefined
