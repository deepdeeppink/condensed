classdef Native < Bridge.Abstract

	methods

		function this = Native()

            this.setNativeFunction(@this.nativeFunction);
		end

		function bridge = uminus(this)

			bridge = copyElement(this);
			bridge.setNativeFunction(@(Q) -this.nativeFunction(-Q));
		end
	end

	methods (Abstract)

		dP = nativeFunction(Q)
	end
end