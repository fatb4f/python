package state

uqamObjectiveOperationalizationIssue: #EngineeringWorkIssue & {
	apiVersion: "python.tracker/v1"
	kind:       "EngineeringWorkIssue"
	origin:     "engineering-intent"

	entity: {
		kind: "learning"
		id:   "uqam-objective-operationalization"
	}

	work: {
		class: "architecture"
		slug:  "operationalize-course-objectives"
	}

	state:    "in-progress"
	priority: "p1"
	objective: "Operationalize the current UQAM INF1120 and INF1035 objective sets through the existing Python Immersion semantic/Ops model using reusable tasks, runtime-specific realizations, and evidence-derived coverage."

	authority: [
		{path: "docs/learning.md", role: "semantic"},
		{path: "docs/ops/README.md", role: "semantic"},
		{path: "docs/architecture/uqam-objective-operationalization/README.md", role: "documentation"},
		{path: "contracts/learning/objectives.cue", role: "semantic"},
		{path: "contracts/learning/uqam_a26.cue", role: "projection"},
	]

	acceptance: [
		{id: "architecture-boundary", statement: "The repository architecture projects UQAM objectives into the existing PPF/Ops model without creating a parallel learning authority.", state: "pending"},
		{id: "typed-objective-contract", statement: "A typed contract covers source provenance, semantic capabilities, operational tasks, realizations, evidence, coverage, and boundary-scoped assessment constraints.", state: "pending"},
		{id: "course-projection", statement: "INF1120 and INF1035 A26 objective groups project through the generic contract without course-specific capability tiers.", state: "pending"},
		{id: "preimplementation-analysis", statement: "Pre-implementation analysis identifies the smallest executable shared Python/Java task and defers unearned abstractions.", state: "pending"},
		{id: "constraint-gap-analysis", statement: "Hard constraints, current gaps, and implementation admission gates are recorded under VCS.", state: "pending"},
		{id: "ops-coverage", statement: "Ops documentation defines evidence-derived objective coverage independently of calendar or chapter completion.", state: "pending"},
		{id: "submission-boundary", statement: "Assessment constraints remain scoped to deliverable/authorship/submission boundaries and do not create global tooling authority.", state: "pending"},
	]

	references: [
		{kind: "issue", ref: "fatb4f/python#6"},
		{kind: "document", ref: "docs/architecture/uqam-objective-operationalization/pre-implementation-analysis.md"},
		{kind: "document", ref: "docs/architecture/uqam-objective-operationalization/constraints-and-gaps.md"},
		{kind: "document", ref: "docs/ops/objective-coverage.md"},
	]
}

uqamObjectiveOperationalizationGitHub: #GitHubEngineeringIssueProjection & {
	issue: uqamObjectiveOperationalizationIssue
	title: "Operationalize UQAM objectives through the Python semantic/Ops model"
}
