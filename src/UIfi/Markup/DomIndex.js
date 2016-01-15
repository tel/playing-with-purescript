/* global exports, require */
"use strict";

// module UiFi.Markup.DomIndex

exports.childAt = function (n) {
  return function (el) {
    return el.childNodes[n];
  };
}
