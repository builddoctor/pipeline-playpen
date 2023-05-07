const express = require('express')
const message = require('./domain.js')


const app = express()

app.disable('x-powered-by');

app.get('/', (req, res) => {
    res.header('Content-Security-Policy', "default-src 'self'; img-src 'self'; child-src 'none'");
    res.header('Strict-Transport-Security', "max-age=31536000; includeSubDomains");
    res.header('X-Frame-Options', "SAMEORIGIN");
    res.header('X-Content-Type-Options', "nosniff");
    res.header('Referrer-Policy', "");
    res.header('Permissions-Policy', "geolocation=()");
    res.send(message());

})

module.exports = app;