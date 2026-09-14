package learning

inf1120Source: #ExternalSourceRef & {
	repository: "fatb4f/factory"
	path:       "academic/uqam/syllabus/inf1120-a26"
	id:         "uqam.inf1120.a26.course-plan"
	role:       "objective-source"
}

inf1035Source: #ExternalSourceRef & {
	repository: "fatb4f/factory"
	path:       "academic/uqam/syllabus/inf1035-a26"
	id:         "uqam.inf1035.a26.course-plan"
	role:       "objective-source"
}

uqamA26: #ObjectiveProjection & {
	id: "uqam.a26.inf1120-inf1035"

	sources: [inf1120Source, inf1035Source]

	capabilities: [
		{id: "representation.typed-values", description: "Represent and interpret values under an explicit type or encoding contract.", facets: ["DATA", "RULE"]},
		{id: "control.predicates-branches", description: "Evaluate predicates and select behavior under explicit conditions.", facets: ["RULE", "OPERATION", "STATE"]},
		{id: "control.iteration-state", description: "Repeat an operation while preserving explicit iteration and accumulator state.", facets: ["RULE", "OPERATION", "STATE", "COMPOSITION"]},
		{id: "composition.callable-decomposition", description: "Decompose behavior into parameterized callable units with explicit result contracts.", facets: ["OPERATION", "COMPOSITION", "BOUNDARY"]},
		{id: "state.object-model", description: "Represent identity, references, encapsulated state, and behavior through objects/classes.", facets: ["DATA", "STATE", "COMPOSITION"]},
		{id: "representation.aggregates", description: "Represent and traverse ordered, keyed, or set-like aggregates.", facets: ["DATA", "OPERATION", "STATE"]},
		{id: "failure.exceptions-validation", description: "Keep invalid input, exceptional behavior, and validation outcomes observable.", facets: ["RULE", "BOUNDARY", "STATE"]},
		{id: "boundary.files-serialization", description: "Cross filesystem and serialization boundaries while preserving representation and failure evidence.", facets: ["DATA", "BOUNDARY", "OPERATION", "COMPOSITION"]},
		{id: "qualification.behavioral", description: "State postconditions and qualify behavior with observable evidence.", facets: ["RULE", "POLICY", "STATE"]},
		{id: "data.structured-scientific", description: "Manipulate structured numeric and tabular data through library-owned representations.", facets: ["DATA", "OPERATION", "COMPOSITION"]},
		{id: "projection.visualization", description: "Project structured data into graphical representations without confusing the projection with the underlying data.", facets: ["DATA", "BOUNDARY", "COMPOSITION"]},
		{id: "model.fit-predict", description: "Fit and apply a library-owned computational model while observing learned state and result contracts.", facets: ["DATA", "OPERATION", "STATE", "COMPOSITION"]},
	]

	objectives: [
		{
			id: "inf1120.problem-analysis-design-testing"
			course: "INF1120"
			statement: "Develop software solutions through problem analysis, simplified design, coding, and testing with attention to reliability, understandability, usability, and modifiability."
			source: inf1120Source
			requires: ["composition.callable-decomposition", "qualification.behavioral"]
		},
		{
			id: "inf1120.java-types-expressions-io"
			course: "INF1120"
			statement: "Use Java types, constants, expressions, conversions, and input/output under the Java execution model."
			source: inf1120Source
			requires: ["representation.typed-values", "boundary.files-serialization"]
		},
		{
			id: "inf1120.control-flow"
			course: "INF1120"
			statement: "Use selections and repetition structures with explicit execution reasoning."
			source: inf1120Source
			requires: ["control.predicates-branches", "control.iteration-state"]
		},
		{
			id: "inf1120.methods-objects-arrays"
			course: "INF1120"
			statement: "Use methods, parameters, returns, classes, objects, references, encapsulation, arrays, and traversal."
			source: inf1120Source
			requires: ["composition.callable-decomposition", "state.object-model", "representation.aggregates"]
		},
		{
			id: "inf1120.exceptions-text-files"
			course: "INF1120"
			statement: "Handle exceptions and text-file boundaries while preserving failure behavior."
			source: inf1120Source
			requires: ["failure.exceptions-validation", "boundary.files-serialization"]
		},
		{
			id: "inf1035.computer-representation-python"
			course: "INF1035"
			statement: "Relate computer representation and execution concepts to Python values, expressions, and execution environments."
			source: inf1035Source
			requires: ["representation.typed-values"]
		},
		{
			id: "inf1035.control-functions"
			course: "INF1035"
			statement: "Use boolean conditions, loops, and functions to express controlled computation."
			source: inf1035Source
			requires: ["control.predicates-branches", "control.iteration-state", "composition.callable-decomposition"]
		},
		{
			id: "inf1035.files-collections-serialization"
			course: "INF1035"
			statement: "Use files, exceptions, lists, tuples, strings, CSV, dictionaries, sets, and JSON as explicit data and boundary representations."
			source: inf1035Source
			requires: ["representation.aggregates", "failure.exceptions-validation", "boundary.files-serialization"]
		},
		{
			id: "inf1035.numpy-pandas"
			course: "INF1035"
			statement: "Use NumPy arrays and Pandas tabular data representations for structured scientific/data computation."
			source: inf1035Source
			requires: ["data.structured-scientific", "representation.aggregates"]
		},
		{
			id: "inf1035.matplotlib"
			course: "INF1035"
			statement: "Project data into graphical representations with Matplotlib."
			source: inf1035Source
			requires: ["projection.visualization", "data.structured-scientific"]
		},
		{
			id: "inf1035.scikit-learn"
			course: "INF1035"
			statement: "Use scikit-learn to fit and apply a machine-learning model while preserving the distinction between data, model state, and predictions."
			source: inf1035Source
			requires: ["model.fit-predict", "data.structured-scientific", "qualification.behavioral"]
		},
	]

	// Submission/evaluation constraints are intentionally not projected as
	// global tooling policy. Add only concrete deliverable-boundary constraints
	// when they are needed by an operational task or submission workflow.
	assessmentConstraints: []

	toolingAuthority: false
}
