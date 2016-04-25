function this = copy_props(this, target)

	prop_names = fieldnames(this);
	for prop_index = 1:length(prop_names)

		name = prop_names{prop_index};
		target.(name) = this.(name);
	end
end