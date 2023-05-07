const request = require("supertest");
const app = require("../src/app");

describe("Test the root path", () => {


  it.each`
    header                   | expectedValue

    ${'content-security-policy'}        | ${"default-src 'self'; img-src 'self'; child-src 'none'"}
    ${'strict-transport-security'}   | ${'max-age=31536000; includeSubDomains'}
    ${'x-frame-options'}    | ${'SAMEORIGIN'}
    ${'x-content-type-options'} | ${'nosniff'}
    ${'referrer-policy'} | ${''}
    ${'permissions-policy'} | ${''}
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



    test("It should not advertise it's technology", () => {
        return request(app)
            .get("/")
            .then(response => {
                expect(response.headers).toEqual(expect.not.objectContaining({'x-powered-by': 'Express'}));
            });
    });
});