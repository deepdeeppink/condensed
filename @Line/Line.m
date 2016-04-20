classdef Line < handle

	properties

		coordinate
		pressure
		velocity
		diameter
	end

	properties (Dependent, SetAccess=private)

		index
		section
	end

	methods

        function this = Line(varargin)

        	if nargin == 1 && isa(varargin{1}, 'Line')

        		source = varargin{1};
        		this.coordinate = source.coordinate;
        		this.pressure = source.pressure;
        		this.velocity = source.velocity;
        		this.diameter = source.diameter;
        	else
	        	
	        	A = struct(varargin{:});

	        	if isfield(A, 'coordinateMax')

					this.coordinate = 0:C.coordinateStep:A.coordinateMax;
				elseif isfield(A, 'coordinate')
	        		
					this.coordinate = A.coordinate;
				end
	        	if isfield(A, 'pressure')
	        		
					this.pressure = A.pressure;
				end
	        	if isfield(A, 'velocity')
	        		
					this.velocity = A.velocity;
				end
	        	if isfield(A, 'diameter')
	        		
					this.diameter = A.diameter;
				end
			end
		end

		function index = get.index(this)

			index = 1:length(this.coordinate);
		end

		function section = get.section(this)

			section = pi * this.diameter^2 / 4;
		end

		function f = leftReducer(this, x)
			
			% x = [pin pout q]
			scale = C.scale;
			v = x(3) * scale.flow / this.section;
			p = reducers.B( ...
				this.pressure(2), ...
				this.velocity(1), ...
				this.velocity(2), ...
				v, ...
				this.diameter);
			f = p - x(2) * scale.pressure;
		end

		function f = rightReducer(this, x)
			
			% x = [pin pout q]
			scale = C.scale;
			v = x(3) * scale.flow / this.section;
			p = reducers.A( ...
				this.pressure(end - 1), ...
				this.velocity(end - 1), ...
				this.velocity(end), ...
				v, ...
				this.diameter);
			f = p - x(1) * scale.pressure;
		end
	end
end