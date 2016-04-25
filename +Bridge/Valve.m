classdef Valve < Bridge.Native

	methods

		function this = Valve(rate)

			this = this@Bridge.Native();
		end

		function dP = nativeFunction(this, Q)

			A = 1.96419e-5;
			Ro = C.density;
			dP = -Ro * Q * abs(Q) / 2 / A;
		end
	end
end