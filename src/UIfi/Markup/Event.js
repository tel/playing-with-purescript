/* global exports, require */
"use strict";

// module UiFi.Markup.Event

var Prelude = require("Prelude");

// forall r eff . Event r -> Eff (handler :: HANDLER | eff) Unit
if (!Event.prototype.preventDefault) {

    // IE8 Polyfill
    exports.preventDefault = function (ev) {
      ev.returnValue = false;
      return Prelude.unit;
    }

  } else {

    exports.preventDefault = function (ev) {
      ev.preventDefault();
      return Prelude.unit;
    }

  }

// forall r eff . Event r -> Eff (handler :: HANDLER | eff) Unit
if (!Event.prototype.stopPropagation) {

    // IE8 Polyfill
    exports.stopPropagation = function (ev) {
      ev.cancelBubble = true;
      return Prelude.unit;
    }

  } else {

    exports.stopPropagation = function (ev) {
      ev.stopPropagation();
      return Prelude.unit;
    }

  }
