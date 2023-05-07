const app = require("./app");
const robots = require("express-robots-txt")
const port = 8080

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

app.use(robots({
  UserAgent: '*',
  Allow: '/',
  CrawlDelay: '1',
  Sitemap: '/sitemap.xml',
}))
