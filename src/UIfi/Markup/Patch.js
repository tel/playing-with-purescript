/* global exports, require */
"use strict";

// module UiFi.Markup.Patch

var Prelude = require("Prelude");

exports.patchRemove = function (el) {
  return function () {
    var parent = el.parentNode;

    if (parent) {
      parent.removeChild(el);
    }

    return Prelude.unit;
  };
};

exports.patchInsert = function (parent) {
  return function (child) {
    return function() {
      parent.appendChild(child);
      return Prelude.unit;
    };
  };
};

function replaceNode(oldEl, newEl) {
  var parent = old.ElparentNode;
  if (parent) {
    parent.replaceChild(newEl, oldEl);
  }
}

exports.patchText = function (el) {
  return function (text) {
    return function() {
      if (el.nodeType === Node.TEXT_NODE) {
        el.textContent = text;
      } else {
        var newEl = document.createTextNode(text);
        replaceNode(el, newEl);
      }
      return Prelude.unit;
    };
  };
}

exports.patchNode = function (oldEl) {
  return function (newEl) {
    return function() {
      replaceNode(el, newEl);
      return Prelude.unit;
    };
  };
}
