classdef TableTest < matlab.unittest.TestCase
	
	properties

		argumentStep = .9
		arguments
		nativeFunction
		testFunction
    end

    methods (TestMethodSetup)

    	function createFunction(testCase)

    		testCase.nativeFunction = @(x) x * x;
    		testCase.arguments = -10:testCase.argumentStep:10;
    		values = arrayfun(@(a) testCase.nativeFunction(a), testCase.arguments);
    		testCase.testFunction = Function.Table(testCase.arguments, values);
    	end
	end

	methods (Test)

		function testAbstractFunctionSignature(testCase)

			testCase.verifyTrue(ismethod(testCase.testFunction, 'eval'));
		end

		function testExactValue(testCase)

			for x = testCase.arguments

				evalValue = testCase.testFunction.eval(x);
				nativeValue = testCase.nativeFunction(x);
				testCase.verifyEqual(evalValue, nativeValue, ...
					'Table function eval must be equal to nativeFunction call on arguments items');
			end
		end

		function testMiddleValue(testCase)

			tol = testCase.nativeFunction(testCase.argumentStep);
			for x = -10 + rand(1, 10) * 20

				evalValue = testCase.testFunction.eval(x);
				nativeValue = testCase.nativeFunction(x);
				testCase.verifyEqual(evalValue, nativeValue, 'AbsTol', tol, ...
					'Table function eval must be equal to nativeFunction call on arguments items');
			end
		end
	end
end