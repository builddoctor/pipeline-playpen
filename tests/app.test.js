const request = require("supertest");
const app = require("../src/app");

describe("Test the app urls", () => {


  it.each`
    header                   | expectedValue

    ${'content-security-policy'}        | ${
    "default-src 'self'; img-src 'self'; child-src 'none'; frame-ancestors 'self'; form-action 'none'"}
    ${'strict-transport-security'}   | ${'max-age=31536000; includeSubDomains'}
    ${'x-frame-options'}    | ${'SAMEORIGIN'}
    ${'x-content-type-options'} | ${'nosniff'}
    ${'referrer-policy'} | ${''}
    ${'cache-control'} | ${'public, max-age=300"'}
    ${'permissions-policy'} | ${'geolocation=()'}
    ${'permissions-policy'} | ${'geolocation=()'}
  `(
    'should return "$expectedValue" when checking "$header"',
    ({ header, expectedValue }) => {
       return request(app)
                .get("/")
                .then(response => {
                    expect(response.headers[header])
                    .toBe(expectedValue);
                });
    },
  );
   test("It should return proper headers everywhere", () => {
   return request(app)
     .get("/sitemap.xml")
     .then(response => {
        expect(response.headers['x-frame-options']).toBe('SAMEORIGIN');
     });
   });


    test("It should not advertise it's technology", () => {
        return request(app)
            .get("/")
            .then(response => {
                expect(response.headers).toEqual(expect.not.objectContaining({'x-powered-by': 'Express'}));
            });
    });
});
