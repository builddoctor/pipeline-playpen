import { Domain } from 'domain'
import express from 'express'
import message from './domain.js'

const app = express()
const port = 3000

app.get('/', (req, res) => {
    res.send(message());
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
