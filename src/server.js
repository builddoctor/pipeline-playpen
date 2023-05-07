const app = require("./app");
const robots = require("express-robots-txt")
const expressSitemapXml = require('express-sitemap-xml')
const port = 8080

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

const getUrls = function() {
  return ["/"];
}

app.use(expressSitemapXml(getUrls, 'https://test-builddoctor-pipeline-playpen.azurewebsites.net/'))

app.use(robots({
  UserAgent: '*',
  Allow: '/',
  CrawlDelay: '1',
  Sitemap: '/sitemap.xml',
}))
