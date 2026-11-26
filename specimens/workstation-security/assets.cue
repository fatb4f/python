package security

// Locations and Unix ownership are deliberately unresolved until qualification.
#ProtectedAsset: close({
	role: "contract" | "bootstrap" | "sudo-policy" | "application-credentials" | "integrity-evidence"
	location: "unresolved"
	ownership: "unresolved"
	workloadMayModify: false
})

#Assets: close({
	contract: #ProtectedAsset & {role: "contract"}
	bootstrap: #ProtectedAsset & {role: "bootstrap"}
	sudoPolicy: #ProtectedAsset & {role: "sudo-policy"}
	applicationCredentials: #ProtectedAsset & {role: "application-credentials"}
	integrityEvidence: #ProtectedAsset & {role: "integrity-evidence"}
})
