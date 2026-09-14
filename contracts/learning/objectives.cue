package learning

#NonEmptyString: string & != ""
#Slug: string & =~ "^[a-z0-9]+(?:[._/-][a-z0-9]+)*$"
#RepositoryPath: string & =~ "^[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$"

#SemanticFacet:
	"DATA" |
	"RULE" |
	"OPERATION" |
	"POLICY" |
	"BOUNDARY" |
	"COMPOSITION" |
	"STATE"

#OpsFamily:
	"O0_CROSS" |
	"O1_OBSERVE" |
	"O2_SELECT_TRANSFORM" |
	"O3_COMPOSE" |
	"O4_CONTROL" |
	"O5_AUTOMATE" |
	"O6_QUALIFY" |
	"O7_INSTRUMENT" |
	"O8_PROJECT"

#CapabilityTier: "T0" | "T1" | "T2" | "T3"

#RuntimeKind:
	"python" |
	"xonsh" |
	"process" |
	"java" |
	"jvm-process" |
	"numpy" |
	"pandas" |
	"matplotlib" |
	"scikit-learn"

#EvidenceKind:
	"explain" |
	"realize" |
	"observe" |
	"validate" |
	"transfer"

#CoverageState:
	"uncovered" |
	"introduced" |
	"exercised" |
	"demonstrated"

#ExternalSourceRef: close({
	repository: #NonEmptyString
	path:       #RepositoryPath
	id:         #Slug
	role:       "objective-source" | "evaluation-source" | "provenance"
})

#SemanticCapability: close({
	id:          #Slug
	description: #NonEmptyString
	facets:      [#SemanticFacet, ...#SemanticFacet]
})

#Objective: close({
	id:          #Slug
	course:      #NonEmptyString
	statement:   #NonEmptyString
	source:      #ExternalSourceRef
	requires:    [#Slug, ...#Slug]
})

#OperationalTask: close({
	id:          #Slug
	statement:   #NonEmptyString
	goal:        #NonEmptyString
	semantics:   [#SemanticFacet, ...#SemanticFacet]
	ops:         [#OpsFamily, ...#OpsFamily]
	constraints: [...#NonEmptyString]
	postconditions: [#NonEmptyString, ...#NonEmptyString]
})

#Realization: close({
	id:       #Slug
	task:     #Slug
	runtime:  #RuntimeKind
	minimumTier: #CapabilityTier
	mechanisms: [#NonEmptyString, ...#NonEmptyString]
	boundaries: [...#NonEmptyString]
	preserves:  [...#NonEmptyString]
	losses?:    [...#NonEmptyString]
})

#EvidenceRequirement: close({
	kind:      #EvidenceKind
	statement: #NonEmptyString
})

#ObjectiveCoverage: close({
	objective: #Slug
	tasks:     [#Slug, ...#Slug]
	evidence:  [#EvidenceRequirement, ...#EvidenceRequirement]
	state:     #CoverageState
})

#AssessmentConstraintScope:
	"submitted-artifact" |
	"authorship-claim" |
	"submission-procedure"

#AssessmentConstraint: close({
	id:        #Slug
	scope:     #AssessmentConstraintScope
	statement: #NonEmptyString
	source:    #ExternalSourceRef
})

#ObjectiveProjection: close({
	id: #Slug
	sources: [#ExternalSourceRef, ...#ExternalSourceRef]
	capabilities: [...#SemanticCapability]
	objectives:   [#Objective, ...#Objective]
	assessmentConstraints?: [...#AssessmentConstraint]

	// External course material provides objective/evaluation evidence only.
	// Private learning/runtime tooling is intentionally outside this authority.
	toolingAuthority: false
})
