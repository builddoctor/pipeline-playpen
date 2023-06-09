const express = require('express')
const message = require('./domain.js')


const app = express()

app.disable('x-powered-by');

app.use((req, res, next) => {
    res.header('Content-Security-Policy', "default-src 'self'; img-src 'self'; child-src 'none'; frame-ancestors 'self'; form-action 'none'");
    res.header('Strict-Transport-Security', "max-age=31536000; includeSubDomains");
    res.header('X-Frame-Options', "SAMEORIGIN");
    res.header('X-Content-Type-Options', "nosniff");
    res.header('Cache-Control', "public, max-age=300, immutable");
    res.header('Referrer-Policy', "");
    res.header('Permissions-Policy', "geolocation=()");
    next();
});

app.get('/', (req, res) => {

    res.send(message());

})

module.exports = app;