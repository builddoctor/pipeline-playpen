const message = require('../src/domain');

test('message is accurate', () => {
    expect(message()).toBe('Hello Amigos')
});

