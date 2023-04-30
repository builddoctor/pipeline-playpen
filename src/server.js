const app = require("./app").default;
const port = 8080

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
