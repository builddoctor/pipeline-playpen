const request = require("supertest");
const app = require("../app");

describe("Test the root path", () => {
    test("It should have a CSP", () => {
        return request(app)
            .get("/")
            .then(response => {

                expect(response.headers['content-security-policy'])
                .toBe("default-src 'self'; img-src https://*; child-src 'none'");
            });
    });

    test("It should not advertise it's technology", () => {
        return request(app)
            .get("/")
            .then(response => {
                console.log(response.headers)
                expect(response.headers).toEqual(expect.not.objectContaining({'x-powered-by': 'Express'}));
            });
    });
});