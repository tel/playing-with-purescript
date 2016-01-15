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

exports.patchInsert = function (parent, child) {
  return function() {
    parent.appendChild(child);
    return Prelude.unit;
  };
};

function replaceNode(oldEl, newEl) {
  var parent = old.ElparentNode;
  if (parent) {
    parent.replaceChild(newEl, oldEl);
  }
};

exports.patchText = function (el, text) {
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

exports.patchNode = function (oldEl, newEl) {
  return function() {
    replaceNode(el, newEl);
    return Prelude.unit;
  };
};

exports.childNodes = function (el) {
  return function () {
    return el.childNodes;
  };
};

exports.removeFrom = function (parent, child) {
  return function () {
    parent.removeChild(child);
    return Prelude.unit;
  };
};

// nextChild may be null---some safari bug?
// I'm definitely cargo culting this at the moment.
//
// See: https://github.com/Matt-Esch/virtual-dom/blob/519fd8d01844206729c64358f4367be7aac55956/vdom/patch-op.js#L140
exports.insertBefore = function (parent, nextChild, child) {
  return function () {
    parent.insertBefore(child, nextChild);
    return Prelude.unit;
  };
};

exports.clearAttr = function (node, name) {
  return function () {
    node.removeAttribute(name);
    return Prelude.unit;
  };
};

exports.setAttr = function (node, name, value) {
  return function () {
    node.setAttribute(name, value);
    return Prelude.unit;
  };
};

exports.clearStyle = function (node, name) {
  return function () {
    node.style[name] = "";
    return Prelude.unit;
  };
};

exports.setStyle = function (node, name, value) {
  return function () {
    node.style[name] = value;
    return Prelude.unit;
  };
};

exports.clearListener = function (node, name) {
  return function () {
    delete node["uifi-listeners"][name];
    return Prelude.unit;
  };
};

exports.setListener = function (node, name, value) {
  return function () {
    node["uifi-listeners"][name] = value;
    return Prelude.unit;
  };
};
