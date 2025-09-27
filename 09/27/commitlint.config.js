// commitlint.config.js
module.exports = {
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'build',
        'chore',
        'ci',
        'docs',
        'feat',
        'fix',
        'perf',
        'refactor',
        'revert',
        'style',
        'test',
        'CRQ' // Add CRQ as a valid type
      ]
    ],
    'type-case': [2, 'always', 'lower-case'],
    'scope-case': [2, 'always', 'kebab-case'],
    'subject-case': [
      2,
      'always',
      ['sentence-case', 'start-case', 'pascal-case', 'upper-case']
    ],
    'header-max-length': [2, 'always', 72],
    'body-leading-blank': [2, 'always'],
    'footer-leading-blank': [2, 'always'],
  }
};
