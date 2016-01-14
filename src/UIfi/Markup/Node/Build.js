/* global exports, require, document */
"use strict";

// module UiFi.Markup.Node.Build

// buildText :: String -> HTMLElement
exports.buildText = function(str) {
  return document.createTextNode(str);
}

// buildElement
//   :: { ns        :: Nullable String
//      , tag       :: String
//      , key       :: Nullable String
//      , attrs     :: Array Attr
//      , listeners :: Array Listener
//      , children  :: Array HTMLElement
//      } -> HTMLElement
exports.buildElement = function(spec) {

  var element;

  // (1) Construct the element
  if (!spec.ns) {
    element = document.createElement(spec.tag);
  } else {
    element = document.createElementNS(spec.ns, spec.tag);
  }

  // (2) Append the user attributes
  spec.attrs.forEach(function (attr) {
    element.setAttribute(attr.name, attr.value);
  });

  // (3) Append styles
  spec.styles.forEach(function (sty) {
    element.style[sty.name] = sty.value;
  });

  // (4) Store the key; clobber user
  element.setAttribute("uifi-key", spec.key);

  // (5) Construct a listener map (for delegation later)
  var listeners = {};

  spec.listeners.forEach(function (listener) {
    listeners[listener.on] = execListener(listener.handle);
  });

  // (6) Append the listener map
  element.setAttribute("uifi-listeners", listeners);

  // (7) Append all of the children
  spec.children.forEach(function (child) {
    element.appendChild(child);
  });

  // (8) Return our beautiful monster
  return element;

}


// Handles Purescript's Eff representation. Prevents us from creating functions
// in a loop.
function execListener(f) {
  return function listen(ev) {
    f(ev)();
  };
}
