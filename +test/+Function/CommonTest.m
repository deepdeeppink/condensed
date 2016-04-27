classdef CommonTest < matlab.unittest.TestCase
	
	properties

		testFunction
	end

	methods (TestMethodSetup)

		function createFunction(testCase)

			testCase.testFunction = Function.Common(@(x) x * x, []);
		end
	end

	methods (Test)

		function testAbstractFunctionSignature(testCase)

			testCase.verifyTrue(ismethod(testCase.testFunction, 'eval'));
		end

		function testNativeFunctionProxy(testCase)

			for x = -.5 + rand(1, 10)

				evalValue = testCase.testFunction.eval(x);
				nativeValue = testCase.testFunction.nativeFunction(x);
				testCase.verifyEqual(evalValue, nativeValue, ...
					'Common function eval must be equal to nativeFunction call');
			end
		end
	end
end