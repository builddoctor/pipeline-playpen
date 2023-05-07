const express = require('express')
const message = require('./domain.js')


const app = express()

app.disable('x-powered-by');

app.get('/', (req, res) => {
    res.set('Content-Security-Policy', "default-src 'self'; img-src 'self'; child-src 'none'");
    res.set('Strict-Transport-Security', "max-age=31536000; includeSubDomains");
    res.set('X-Frame-Options', "SAMEORIGIN");
    res.set('X-Content-Type-Options', "nosniff");
    res.set('Referrer-Policy', "");
    res.set('Permissions-Policy', "");
    res.send(message());

})

module.exports = app;