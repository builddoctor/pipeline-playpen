/** @type {import('jest').Config} */
const config = {
    collectCoverage: true,
    coverageReporters: ['json', 'text', 'lcov', 'cobertura'],
    coverageDirectory: 'build/coverage',

    reporters: [
        'default',
        ['jest-junit', { outputDirectory: 'build/reports', outputName: 'report.xml' }],
    ],
};

module.exports = config;