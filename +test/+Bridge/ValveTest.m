classdef ValveTest < matlab.unittest.TestCase
	
	properties

		bridge
    end

    methods (TestMethodSetup)

    	function createBridge(testCase)

			testCase.bridge = Bridge.Valve([]);
    	end
	end

	methods (Test)

		function testZeroValue(testCase)

			testCase.verifyEqual(0, testCase.bridge.stateFunction.eval(0), ...
				'Zero pressure drop at valve with no flow');
		end
	end
end