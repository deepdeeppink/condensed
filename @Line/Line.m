classdef Line < handle

	properties

		coordinate
		pressure
		velocity
		diameter
	end

	properties (Dependent)

		index
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
	end
end