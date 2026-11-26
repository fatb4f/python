package security

// A command grant is a potential future policy, not an active v0.1 grant.
// A shell or interpreter can confer interactive authority and is not admitted.
#CommandGrant: close({
	source: "operator"
	target: "developer" | "chatgpt"
	kind: "command"
	executable: string & =~"^/" & !~"(^|/)(sh|bash|zsh|xonsh|fish|python[0-9.]*|env|sudo|su)$"
	arguments: [...string]
	interactive: false
})

#InteractiveGrant: close({
	source: "operator"
	target: "developer" | "chatgpt"
	kind: "interactive"
})

// Closed-world baseline: no transition is currently authorized.
#Authority: close({
	commandGrants: []
	interactiveGrants: []
})

#Contract: close({
	identities: #Identities
	authority: #Authority
	assets: #Assets
	recovery: #Recovery
})
