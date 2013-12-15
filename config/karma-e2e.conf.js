basePath = '../';

files = [
  ANGULAR_SCENARIO,
  ANGULAR_SCENARIO_ADAPTER,
  'test/e2e/**/*.js',
  'test/e2e/**/*.coffee'
];

autoWatch = false;

browsers = ['Chrome'];

singleRun = true;

proxies = {
  '/': 'http://localhost:8000/'
};

junitReporter = {
  outputFile: 'test_out/e2e.xml',
  suite: 'e2e'
};
