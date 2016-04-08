classdef CheckValve < Bridge.Native

	methods

		function this = CheckValve()

			this = this@Bridge.Native();
		end

		function dP = nativeFunction(this, Q)

			if Q >= 0
				
				dP = 0;
			else

				P0 = 1e+5 * C.airPressure;
				Q0 = 3.6 / 60;
				dP = P0 * (exp(-Q / Q0) - 1);
			end
		end
	end
end