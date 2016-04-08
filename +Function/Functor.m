classdef Functor < handle

	methods (Abstract)

		eval
	end

	methods

		function y = subsref(this, ref)

            x = ref.subs{1};
            y = this.eval(x);
        end
	end
end