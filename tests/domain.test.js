const message = require('../domain');

test('message is accurate', () => {
    expect(message()).toBe('Hello Amigos')
});

