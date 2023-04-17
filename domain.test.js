const message = require('./domain').default;

test('message is accurate', () => {
    expect(message()).toBe('Hello Amigos')
});

