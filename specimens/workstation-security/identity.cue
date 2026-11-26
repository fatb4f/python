package security

// These are intended roles, not claims about existing accounts.
#Identity: close({
	name: string & !=""
	role: "administration" | "operator" | "development" | "application" | "observation" | "system"
	interactiveLogin: bool
})

#Identities: close({
	"_404":   #Identity & {name: "_404", role: "administration", interactiveLogin: true}
	operator: #Identity & {name: "operator", role: "operator", interactiveLogin: true}
	developer: #Identity & {name: "developer", role: "development", interactiveLogin: false}
	chatgpt: #Identity & {name: "chatgpt", role: "application", interactiveLogin: false}
	observer: #Identity & {name: "observer", role: "observation", interactiveLogin: false}
	root: #Identity & {name: "root", role: "system", interactiveLogin: false}
})
