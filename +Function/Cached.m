classdef Cached < Function.Functor

	properties

		sourceFunction
	end

	properties
	% properties (Hidden)

		arguments
		results
		argumentTolerance
		resultTolerance
		interpolationMask
	end

	methods

		function this = Cached(sourceFunction, argumentTolerance, resultTolerance)

			this.sourceFunction = sourceFunction;
			this.argumentTolerance = argumentTolerance;
			this.resultTolerance = resultTolerance;
		end

		function y = eval(this, x)

			y = this.load(x);

			if isnan(y)

				disp(['non cached ' num2str(x)])
				y = this.sourceFunction(x);
				this.save(x, y);
			end
		end

		function save(this, x, y)

			index = find(this.arguments < x, 1, 'last');
			if ~any(index)
				index = 0;
			end
			this.arguments = [this.arguments(1:index) x this.arguments(index + 1:end)];
			this.results = [this.results(1:index) y this.results(index + 1:end)];
		end

		function y = load(this, x) % from cache

			y = NaN;
			index = find(this.arguments <= x, 1, 'last');
			if any(index)

				if this.arguments(index) == x

					y = this.results(index);
				elseif index < length(this.arguments)

					dx = this.arguments(index + 1) - this.arguments(index);
					dy = this.results(index + 1) - this.results(index);
					if dx <= this.argumentTolerance && dy <= this.resultTolerance

						y = interp1(this.arguments(index:index + 1), this.results(index:index + 1), x);
					end
				end
			end
		end
	end
end