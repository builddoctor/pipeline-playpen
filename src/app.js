const express = require('express')
const message = require('./domain.js')


const app = express()

app.disable('x-powered-by');

app.get('/', (req, res) => {
    res.set('Content-Security-Policy', "default-src 'self'; img-src https://*; child-src 'none'");
    res.send(message());

})

module.exports = app;