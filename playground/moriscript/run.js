// run.js
var fs = require('fs');
var babel = require('babel-core');
var moriscript = require('./moriscript');

//read the filename from the command line arguments
var fileName = process.argv[2];

//read the code from this file
fs.readFile(fileName, function(err, data) {
  if (err) throw err;

  //convert from a buffer to a string
  var src = data.toString();

  //user our plugin to transform the source
  var out = babel.transform(src, {
    plugins: [moriscript],
  });

  //print the generated code to screen
  console.log(out.code);
});
