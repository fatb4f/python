package state

#TrackerSchema: "python.tracker/v1"
#TrackerOrigin: "engineering-intent" | "evidence-derived"
#TrackerState: "backlog" | "ready" | "in-progress" | "blocked" | "done" | "suppressed"
#TrackerPriority: "p0" | "p1" | "p2" | "p3"

#TrackedEntityKind:
	"learning" |
	"runtime" |
	"environment" |
	"tooling" |
	"workflow" |
	"project" |
	"contract" |
	"adapter"

#EngineeringWorkClass:
	"architecture" |
	"schema" |
	"realization" |
	"projection" |
	"adapter" |
	"integration" |
	"qualification" |
	"migration" |
	"documentation" |
	"investigation"

#NonEmptyString: string & !=""
#Slug: string & =~"^[a-z0-9]+(?:-[a-z0-9]+)*$"
#EntityID: string & =~"^[a-z0-9]+(?:[._/-][a-z0-9]+)*$"
#IssueKey: string & =~"^(engineering|evidence):[a-z0-9][a-z0-9._:/-]*$"
#RepositoryPath: string & =~"^[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$"

#TrackedEntityRef: close({
	kind: #TrackedEntityKind
	id:   #EntityID
})

#AuthorityRef: close({
	path: #RepositoryPath
	role: "semantic" | "implementation" | "projection" | "procedure" | "documentation"
})

#IssueDependency: close({
	key: #IssueKey
	relation: "depends-on" | "blocks" | "blocked-by" | "projects-to" | "implements" | "consumes"
})

#AcceptanceCriterion: close({
	id:        #Slug
	statement: #NonEmptyString
	state:     "pending" | "satisfied" | "waived"
	if state == "waived" {
		reason: #NonEmptyString
	}
})

#TrackerReference: close({
	kind: "run" | "evidence" | "document" | "commit" | "issue" | "url"
	ref:  #NonEmptyString
})

#EngineeringWorkIssue: close({
	apiVersion: #TrackerSchema
	kind:       "EngineeringWorkIssue"
	origin:     "engineering-intent"

	entity: #TrackedEntityRef
	work: close({
		class: #EngineeringWorkClass
		slug:  #Slug
	})

	key: "engineering:\(entity.kind):\(entity.id):\(work.class):\(work.slug)"

	state:     #TrackerState
	priority:  #TrackerPriority
	objective: #NonEmptyString

	authority: [#AuthorityRef, ...#AuthorityRef]
	dependencies?: [...#IssueDependency]
	acceptance: [#AcceptanceCriterion, ...#AcceptanceCriterion]
	references?: [...#TrackerReference]
})

#EvidenceDerivedIssue: close({
	apiVersion: #TrackerSchema
	kind:       "EvidenceDerivedIssue"
	origin:     "evidence-derived"

	entity:      #TrackedEntityRef
	issue_class: #Slug
	slug:        #Slug

	key: "evidence:\(entity.kind):\(entity.id):\(issue_class):\(slug)"

	state:    #TrackerState
	priority: #TrackerPriority

	runs:     [#TrackerReference & {kind: "run"}, ...#TrackerReference & {kind: "run"}]
	evidence: [#TrackerReference & {kind: "evidence"}, ...#TrackerReference & {kind: "evidence"}]

	admission: close({
		authority: #RepositoryPath
		decision:  #NonEmptyString
	})

	dependencies?: [...#IssueDependency]
	references?: [...#TrackerReference]
})

#TrackerIssue: #EngineeringWorkIssue | #EvidenceDerivedIssue

#GitHubIssueProjectionBase: {
	issue:         #TrackerIssue
	title:         #NonEmptyString
	managedLabels: [#NonEmptyString, ...#NonEmptyString]

	markers: close({
		python_schema:      issue.apiVersion
		python_issue_key:   issue.key
		python_origin:      issue.origin
		python_entity_kind: issue.entity.kind
		python_entity_id:   issue.entity.id
	})
}

#GitHubEngineeringIssueProjection: close(#GitHubIssueProjectionBase & {
	issue: #EngineeringWorkIssue
	managedLabels: [
		"python",
		"origin:engineering",
		"entity:\(issue.entity.kind)",
		"state:\(issue.state)",
		"priority:\(issue.priority)",
		"work:\(issue.work.class)",
	]
})

#GitHubEvidenceIssueProjection: close(#GitHubIssueProjectionBase & {
	issue: #EvidenceDerivedIssue
	managedLabels: [
		"python",
		"origin:evidence",
		"entity:\(issue.entity.kind)",
		"state:\(issue.state)",
		"priority:\(issue.priority)",
	]
})

#GitHubIssueProjection: #GitHubEngineeringIssueProjection | #GitHubEvidenceIssueProjection

trackerProtocol: close({
	semanticIdentity: "python-issue-key"
	externalTracker:  "github-issues"
	correlateByTitle: false
	origins: [
		"engineering-intent",
		"evidence-derived",
	]
	managedLabels: close({
		ownershipMarker: "python"
		prefixes: [
			"origin:",
			"entity:",
			"state:",
			"priority:",
			"work:",
		]
		preserveUnmanaged: true
		reconcileAsSet:    true
	})
	actions: [
		"create",
		"update",
		"append-evidence",
		"resolve",
		"reopen",
		"suppress",
		"no-op",
	]
})
