package state

engineeringFixture: #EngineeringWorkIssue & {
	apiVersion: "python.tracker/v1"
	kind:       "EngineeringWorkIssue"
	origin:     "engineering-intent"
	entity: {
		kind: "runtime"
		id:   "xonsh"
	}
	work: {
		class: "migration"
		slug:  "interactive-shell-cutover"
	}
	state:     "ready"
	priority:  "p0"
	objective: "Qualify and perform the bounded Xonsh interactive-shell cutover."
	authority: [{
		path: "docs/xonsh/implementation.md"
		role: "semantic"
	}]
	acceptance: [{
		id:        "qualified-cutover"
		statement: "The qualified login, environment, interactive-shell, and rollback boundaries hold after cutover."
		state:     "pending"
	}]
}

engineeringProjectionFixture: #GitHubIssueProjection & {
	issue: engineeringFixture
	title: "Qualify Xonsh interactive-shell cutover"
	managedLabels: [
		"python",
		"origin:engineering",
		"entity:runtime",
		"state:ready",
		"priority:p0",
		"work:migration",
	]
}

evidenceFixture: #EvidenceDerivedIssue & {
	apiVersion: "python.tracker/v1"
	kind:       "EvidenceDerivedIssue"
	origin:     "evidence-derived"
	entity: {
		kind: "tooling"
		id:   "typed-explorer"
	}
	issue_class: "qualification-regression"
	slug:        "runtime-introspection"
	state:       "ready"
	priority:    "p2"
	runs: [{
		kind: "run"
		ref:  "tests/test_runtime_explorer.py"
	}]
	evidence: [{
		kind: "evidence"
		ref:  "pytest failure: runtime introspection contract"
	}]
	admission: {
		authority: "docs/semantics/typed-python-explorer.md"
		decision:  "The documented explorer contract admits the continuing regression."
	}
}

evidenceProjectionFixture: #GitHubIssueProjection & {
	issue: evidenceFixture
	title: "Track typed explorer runtime-introspection regression"
	managedLabels: [
		"python",
		"origin:evidence",
		"entity:tooling",
		"state:ready",
		"priority:p2",
	]
}
