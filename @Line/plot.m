function handler = plot(this, varargin)

	% handler = plot(this.coordinate, this.velocity, varargin{:});
	handler = plot(this.coordinate, this.pressure, varargin{:});
end