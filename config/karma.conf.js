basePath = '../';

files = [
  JASMINE,
  JASMINE_ADAPTER,
  'app/lib/angular/angular.js',
  'app/lib/angular/angular-*.js',
  'test/lib/angular/angular-mocks.js',
  'app/js/**/*.js',
  'app/coffee/**/*.coffee',
  'test/unit/**/*.js',
  'test/unit/**/*.coffee'
];

autoWatch = true;

browsers = ['Chrome'];

preprocessors = {
  '**/*.coffee': 'coffee',
};

junitReporter = {
  outputFile: 'test_out/unit.xml',
  suite: 'unit'
};
