classdef Native < Bridge.Abstract

	methods

		function this = Native()

            try
                this.setNativeFunction(@this.nativeFunction);
            catch err
                1
            end
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