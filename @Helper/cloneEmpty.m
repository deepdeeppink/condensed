function emptyInstance = cloneEmpty(instance)

	emptyInstance = eval([class(instance) '.empty']);
end