package catalogue

// The template reads every field with hasKey, so a misspelled key is not an
// error — the setting just vanishes. Closed structs turn that back into one.

#Name: =~"^[a-z0-9]([a-z0-9-]*[a-z0-9])?$"

#ResourceSet: {
	apiVersion: "fluxcd.controlplane.io/v1"
	kind:       "ResourceSet"
	metadata: {
		name:      "apps-\(spec.inputs[0].namespace)"
		namespace: "flux-system"
	}
	spec: inputs: [#Input]
}

#Input: {
	namespace: #Name
	apps: [...#App]
}

#App: {
	app: #Name

	// No path may carry a cluster name.
	path?: =~"^\\./kubernetes/apps/[a-z0-9-]+(/[a-z0-9-]+)+$"

	targetNamespace?: #Name
	dependsOn?: [...{name: #Name, namespace?: #Name}]
	components?: [...string]
	healthChecks?: [...{apiVersion: string, kind: string, name: string, namespace?: string}]
	healthCheckExprs?: [...{apiVersion: string, kind: string, current?: string, inProgress?: string, failed?: string}]
	commonMetadata?: {labels?: [string]: string, annotations?: [string]: string}
	patches?: [...{...}]
	substitute?: [string]: string
	wait?:  bool
	force?: bool
}
