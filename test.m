suite = matlab.unittest.TestSuite.fromPackage('test', 'IncludingSubpackages', true);
result = suite.run;
disp(result)