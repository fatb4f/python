package security

#Recovery: close({
	administrator: "_404"
	// This baseline cannot authorize provisioning. A later revision must
	// require evidence of independent access and rollback before doing so.
	status: "unverified"
	independentAccessVerified: false
	rollbackVerified: false
	provisioningAllowed: false
})
