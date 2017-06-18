//moriscript.js
module.exports = function(babel) {
  var t = babel.types;

  function moriMethod(name) {
    return t.memberExpression(t.identifier('mori'), t.identifier(name));
  }

  return {
    visitor: {
      ObjectExpression(path) {
        const props = [];

        path.node.properties.forEach(prop => {
          props.push(t.stringLiteral(prop.key.name), prop.value);
        });

        path.replaceWith(t.callExpression(moriMethod('hashMap'), props));
      },
      ArrayExpression(path) {
        path.replaceWith(t.callExpression(moriMethod('vector'), path.node.elements));
      },
    },
  };
};
