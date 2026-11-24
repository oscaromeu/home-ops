stringData: [string]: string

#fake: {
	key:   string
	value: string

	if key =~ "_PORT$" {value: "6443"}
	if key =~ "_CIDR$" {value: "192.0.2.0/24"}
	if key =~ "(_IP|_LB.*)$" {value: "192.0.2.10"}
	if key =~ "_DNS$" {value: "cluster.local"}
	if key =~ "_DOMAIN$" {value: "example.com"}
	if key =~ "_DN$" {value: "dc=example,dc=com"}
	if key =~ "_MAIL$" {value: "ci@example.com"}
	if key =~ "_PATH$" {value: "/ci/media"}
	if key =~ "_SECRET$" {value: "ci-placeholder"}
	if key =~ "_DISPLAYNAME$" {value: "CI Admin"}
	if key =~ "_USER$" {value: "ci"}
	if key == "CLUSTER_NAME" {value: "ci"}
	if key == "STORAGE_CLASS" {value: "openebs-hostpath"}
	if key == "OP_VAULT" {value: "ci"}
	if key == "TZ" {value: "Etc/UTC"}
}

let keys = stringData

out: {
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {name: "cluster-secrets", namespace: "flux-system"}
	stringData: {
		for k, _ in keys {(k): (#fake & {key: k}).value}
	}
}
