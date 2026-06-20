const EventEmitter = require('events');

class EventBus extends EventEmitter {}

const eventBus = new EventBus();

// Exemple d'utilisation : eventBus.on('userRegistered', (user) => { ... })
// eventBus.emit('userRegistered', newUser);

module.exports = eventBus;
