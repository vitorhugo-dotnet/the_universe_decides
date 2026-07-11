(function () {
  'use strict';

  function emit(event) {
    if (window.DiceBridgeChannel && window.DiceBridgeChannel.postMessage) {
      window.DiceBridgeChannel.postMessage(JSON.stringify(event));
    }
  }

  function validRoll(roll) {
    if (!roll || typeof roll.requestId !== 'string' || !roll.requestId ||
        typeof roll.notation !== 'string' || !Array.isArray(roll.results)) {
      return false;
    }
    var match = /^([1-9]\d*)d(4|6|8|10|12|20|100)$/.exec(roll.notation);
    if (!match || Number(match[1]) !== roll.results.length) return false;
    var sides = Number(match[2]);
    return roll.results.every(function (result) {
      return Number.isInteger(result) && result >= 1 && result <= sides;
    });
  }

  var diceBox = new DICE.dice_box(document.body);
  var activeRequestId = null;

  window.addEventListener('resize', function () {
    diceBox.reinit(document.body);
  });

  window.DiceBridge = {
    roll: function (roll) {
      if (!validRoll(roll)) {
        emit({ type: 'error', requestId: roll && roll.requestId, message: 'Invalid roll' });
        return;
      }
      if (activeRequestId !== null) {
        emit({ type: 'error', requestId: roll.requestId, message: 'A roll is already active' });
        return;
      }
      activeRequestId = roll.requestId;
      emit({ type: 'rollStarted', requestId: roll.requestId });
      diceBox.setDice(roll.notation);
      diceBox.start_throw(function () {
        return roll.results;
      }, function () {
        activeRequestId = null;
        emit({ event: 'rollCompleted', requestId: roll.requestId, results: roll.results });
      });
    },
    pause: function () { diceBox.pause(); },
    resume: function () { diceBox.resume(); }
  };

  document.addEventListener('contextmenu', function (event) { event.preventDefault(); });
  emit({ type: 'ready' });
}());
