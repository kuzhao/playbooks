apiVersion: v1
appVersion: 0.26.1
description: An nginx Ingress controller that uses ConfigMap to store the nginx configuration.
engine: gotpl
home: https://github.com/kubernetes/ingress-nginx
icon: https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nginx_logo.svg/500px-Nginx_logo.svg.png
keywords:
- ingress
- nginx
kubeVersion: '>=1.10.0-0'
maintainers:
- name: ChiefAlexander
- email: Trevor.G.Wood@gmail.com
  name: taharah
name: nginx-ingress
sources:
- https://github.com/kubernetes/ingress-nginx
version: 1.24.1

---
## nginx configuration
## Ref: https://github.com/kubernetes/ingress/blob/master/controllers/nginx/configuration.md
##
controller:
  name: controller
  image:
    repository: quay.io/kubernetes-ingress-controller/nginx-ingress-controller
    tag: "0.26.1"
    pullPolicy: IfNotPresent
    # www-data -> uid 33
    runAsUser: 33
    allowPrivilegeEscalation: true

  # Can be changed to old api for compatibility reasons: extensions/v1beta1
  apiVersion: apps/v1

  # Configures the ports the nginx-controller listens on
  containerPort:
    http: 80
    https: 443

  # Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
  config: {}

  # Will add custom headers before sending traffic to backends according to https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/customization/custom-headers
  proxySetHeaders: {}

  # Will add custom headers before sending response traffic to the client according to: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers
  addHeaders: {}

  # Required for use with CNI based kubernetes installations (such as ones set up by kubeadm),
  # since CNI and hostport don't mix yet. Can be deprecated once https://github.com/kubernetes/kubernetes/issues/23920
  # is merged
  hostNetwork: false

  # Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true'.
  # By default, while using host network, name resolution uses the host's DNS. If you wish nginx-controller
  # to keep resolving names inside the k8s network, use ClusterFirstWithHostNet.
  dnsPolicy: ClusterFirst

  # Bare-metal considerations via the host network https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network
  # Ingress status was blank because there is no Service exposing the NGINX Ingress controller in a configuration using the host network, the default --publish-service flag used in standard cloud setups does not apply
  reportNodeInternalIp: false

  ## Use host ports 80 and 443
  daemonset:
    useHostPort: false

    hostPorts:
      http: 80
      https: 443

  ## Required only if defaultBackend.enabled = false
  ## Must be <namespace>/<service_name>
  ##
  defaultBackendService: ""

  ## Election ID to use for status update
  ##
  electionID: ingress-controller-leader

  ## Name of the ingress class to route through this controller
  ##
  ingressClass: nginx

  # labels to add to the pod container metadata
  podLabels: {}
  #  key: value

  ## Security Context policies for controller pods
  ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
  ## notes on enabling and using sysctls
  ##
  podSecurityContext: {}

  ## Allows customization of the external service
  ## the ingress will be bound to via DNS
  publishService:
    enabled: false
    ## Allows overriding of the publish service to bind to
    ## Must be <namespace>/<service_name>
    ##
    pathOverride: ""

  ## Limit the scope of the controller
  ##
  scope:
    enabled: false
    namespace: ""   # defaults to .Release.Namespace

  ## Allows customization of the configmap / nginx-configmap namespace
  ##
  configMapNamespace: ""   # defaults to .Release.Namespace

  ## Allows customization of the tcp-services-configmap namespace
  ##
  tcp:
    configMapNamespace: ""   # defaults to .Release.Namespace

  ## Allows customization of the udp-services-configmap namespace
  ##
  udp:
    configMapNamespace: ""   # defaults to .Release.Namespace

  ## Additional command line arguments to pass to nginx-ingress-controller
  ## E.g. to specify the default SSL certificate you can use
  ## extraArgs:
  ##   default-ssl-certificate: "<namespace>/<secret_name>"
  extraArgs: {}

  ## Additional environment variables to set
  extraEnvs: []
  # extraEnvs:
  #   - name: FOO
  #     valueFrom:
  #       secretKeyRef:
  #         key: FOO
  #         name: secret-resource

  ## DaemonSet or Deployment
  ##
  kind: Deployment

  # The update strategy to apply to the Deployment or DaemonSet
  ##
  updateStrategy: {}
  #  rollingUpdate:
  #    maxUnavailable: 1
  #  type: RollingUpdate

  # minReadySeconds to avoid killing pods before we are ready
  ##
  minReadySeconds: 0


  ## Node tolerations for server scheduling to nodes with taints
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  ##
  tolerations: []
  #  - key: "key"
  #    operator: "Equal|Exists"
  #    value: "value"
  #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  ## Affinity and anti-affinity
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ##
  affinity: {}
    # # An example of preferred pod anti-affinity, weight is in the range 1-100
    # podAntiAffinity:
    #   preferredDuringSchedulingIgnoredDuringExecution:
    #   - weight: 100
    #     podAffinityTerm:
    #       labelSelector:
    #         matchExpressions:
    #         - key: app
    #           operator: In
    #           values:
    #           - nginx-ingress
    #       topologyKey: kubernetes.io/hostname

    # # An example of required pod anti-affinity
    # podAntiAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #   - labelSelector:
    #       matchExpressions:
    #       - key: app
    #         operator: In
    #         values:
    #         - nginx-ingress
    #     topologyKey: "kubernetes.io/hostname"

  ## terminationGracePeriodSeconds
  ##
  terminationGracePeriodSeconds: 60

  ## Node labels for controller pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}

  ## Liveness and readiness probe values
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ##
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
    port: 10254
  readinessProbe:
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
    port: 10254

  ## Annotations to be added to controller pods
  ##
  podAnnotations: {}

  replicaCount: 1

  minAvailable: 1

  resources: {}
  #  limits:
  #    cpu: 100m
  #    memory: 64Mi
  #  requests:
  #    cpu: 100m
  #    memory: 64Mi

  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 11
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50

  ## Override NGINX template
  customTemplate:
    configMapName: ""
    configMapKey: ""

  service:
    enabled: true

    annotations: {}
    labels: {}
    omitClusterIP: false
    clusterIP: ""

    ## List of IP addresses at which the controller services are available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    loadBalancerIP: ""
    loadBalancerSourceRanges: []

    enableHttp: true
    enableHttps: true

    ## Set external traffic policy to: "Local" to preserve source IP on
    ## providers supporting it
    ## Ref: https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
    externalTrafficPolicy: ""

    healthCheckNodePort: 0

    ports:
      http: 80
      https: 443

    targetPorts:
      http: http
      https: https

    type: LoadBalancer

    # type: NodePort
    # nodePorts:
    #   http: 32080
    #   https: 32443
    #   tcp:
    #     8080: 32808
    nodePorts:
      http: ""
      https: ""
      tcp: {}
      udp: {}

  extraContainers: []
  ## Additional containers to be added to the controller pod.
  ## See https://github.com/lemonldap-ng-controller/lemonldap-ng-controller as example.
  #  - name: my-sidecar
  #    image: nginx:latest
  #  - name: lemonldap-ng-controller
  #    image: lemonldapng/lemonldap-ng-controller:0.2.0
  #    args:
  #      - /lemonldap-ng-controller
  #      - --alsologtostderr
  #      - --configmap=$(POD_NAMESPACE)/lemonldap-ng-configuration
  #    env:
  #      - name: POD_NAME
  #        valueFrom:
  #          fieldRef:
  #            fieldPath: metadata.name
  #      - name: POD_NAMESPACE
  #        valueFrom:
  #          fieldRef:
  #            fieldPath: metadata.namespace
  #    volumeMounts:
  #    - name: copy-portal-skins
  #      mountPath: /srv/var/lib/lemonldap-ng/portal/skins

  extraVolumeMounts: []
  ## Additional volumeMounts to the controller main container.
  #  - name: copy-portal-skins
  #   mountPath: /var/lib/lemonldap-ng/portal/skins

  extraVolumes: []
  ## Additional volumes to the controller pod.
  #  - name: copy-portal-skins
  #    emptyDir: {}

  extraInitContainers: []
  ## Containers, which are run before the app containers are started.
  # - name: init-myservice
  #   image: busybox
  #   command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']

  admissionWebhooks:
    enabled: false
    failurePolicy: Fail
    port: 8443

    service:
      annotations: {}
      omitClusterIP: false
      clusterIP: ""
      externalIPs: []
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      servicePort: 443
      type: ClusterIP

    patch:
      enabled: true
      image:
        repository: jettech/kube-webhook-certgen
        tag: v1.0.0
        pullPolicy: IfNotPresent
      ## Provide a priority class name to the webhook patching job
      ##
      priorityClassName: ""
      podAnnotations: {}
      nodeSelector: {}

  metrics:
    enabled: false

    service:
      annotations: {}
      # prometheus.io/scrape: "true"
      # prometheus.io/port: "10254"

      omitClusterIP: false
      clusterIP: ""

      ## List of IP addresses at which the stats-exporter service is available
      ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
      ##
      externalIPs: []

      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      servicePort: 9913
      type: ClusterIP

    serviceMonitor:
      enabled: false
      additionalLabels: {}
      namespace: ""
      scrapeInterval: 30s
      # honorLabels: true

    prometheusRule:
      enabled: false
      additionalLabels: {}
      namespace: ""
      rules: []
        # # These are just examples rules, please adapt them to your needs
        # - alert: TooMany500s
        #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
        #   for: 1m
        #   labels:
        #     severity: critical
        #   annotations:
        #     description: Too many 5XXs
        #     summary: More than 5% of the all requests did return 5XX, this require your attention
        # - alert: TooMany400s
        #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
        #   for: 1m
        #   labels:
        #     severity: critical
        #   annotations:
        #     description: Too many 4XXs
        #     summary: More than 5% of the all requests did return 4XX, this require your attention


  lifecycle: {}

  priorityClassName: ""

## Rollback limit
##
revisionHistoryLimit: 10

## Default 404 backend
##
defaultBackend:

  ## If false, controller.defaultBackendService must be provided
  ##
  enabled: true

  # Can be changed to old api for compatibility reasons: extensions/v1beta1
  apiVersion: apps/v1

  name: default-backend
  image:
    repository: k8s.gcr.io/defaultbackend-amd64
    tag: "1.5"
    pullPolicy: IfNotPresent
    # nobody user -> uid 65534
    runAsUser: 65534

  extraArgs: {}

  serviceAccount:
    create: true
    name:
  ## Additional environment variables to set for defaultBackend pods
  extraEnvs: []

  port: 8080

  ## Readiness and liveness probes for default backend
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  ##
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 30
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  readinessProbe:
    failureThreshold: 6
    initialDelaySeconds: 0
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 5

  ## Node tolerations for server scheduling to nodes with taints
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  ##
  tolerations: []
  #  - key: "key"
  #    operator: "Equal|Exists"
  #    value: "value"
  #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  affinity: {}

  ## Security Context policies for controller pods
  ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
  ## notes on enabling and using sysctls
  ##
  podSecurityContext: {}

  # labels to add to the pod container metadata
  podLabels: {}
  #  key: value

  ## Node labels for default backend pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}

  ## Annotations to be added to default backend pods
  ##
  podAnnotations: {}

  replicaCount: 1

  minAvailable: 1

  resources: {}
  # limits:
  #   cpu: 10m
  #   memory: 20Mi
  # requests:
  #   cpu: 10m
  #   memory: 20Mi

  service:
    annotations: {}
    omitClusterIP: false
    clusterIP: ""

    ## List of IP addresses at which the default backend service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    type: ClusterIP

  priorityClassName: ""

## Enable RBAC as per https://github.com/kubernetes/ingress/tree/master/examples/rbac/nginx and https://github.com/kubernetes/ingress/issues/266
rbac:
  create: true

# If true, create & use Pod Security Policy resources
# https://kubernetes.io/docs/concepts/policy/pod-security-policy/
podSecurityPolicy:
  enabled: false

serviceAccount:
  create: true
  name:

## Optional array of imagePullSecrets containing private registry credentials
## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []
# - name: secretName

# TCP service key:value pairs
# Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/tcp
##
tcp: {}
#  8080: "default/example-tcp-svc:9000"

# UDP service key:value pairs
# Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/udp
##
udp: {}
#  53: "kube-system/kube-dns:53"

---
# nginx-ingress

[nginx-ingress](https://github.com/kubernetes/ingress-nginx) is an Ingress controller that uses ConfigMap to store the nginx configuration.

To use, add the `kubernetes.io/ingress.class: nginx` annotation to your Ingress resources.

## TL;DR;

```console
$ helm install stable/nginx-ingress
```

## Introduction

This chart bootstraps an nginx-ingress deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

  - Kubernetes 1.6+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/nginx-ingress
```

The command deploys nginx-ingress on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the nginx-ingress chart and their default values.

Parameter | Description | Default
--- | --- | ---
`controller.name` | name of the controller component | `controller`
`controller.image.repository` | controller container image repository | `quay.io/kubernetes-ingress-controller/nginx-ingress-controller`
`controller.image.tag` | controller container image tag | `0.26.1`
`controller.image.pullPolicy` | controller container image pull policy | `IfNotPresent`
`controller.image.runAsUser` | User ID of the controller process. Value depends on the Linux distribution used inside of the container image. By default uses debian one. | `33`
`controller.containerPort.http` | The port that the controller container listens on for http connections. | `80`
`controller.containerPort.https` | The port that the controller container listens on for https connections. | `443`
`controller.config` | nginx [ConfigMap](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md) entries | none
`controller.hostNetwork` | If the nginx deployment / daemonset should run on the host's network namespace. Do not set this when `controller.service.externalIPs` is set and `kube-proxy` is used as there will be a port-conflict for port `80` | false
`controller.defaultBackendService` | default 404 backend service; needed only if `defaultBackend.enabled = false` | `""`
`controller.dnsPolicy` | If using `hostNetwork=true`, change to `ClusterFirstWithHostNet`. See [pod's dns policy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy) for details | `ClusterFirst`
`controller.reportNodeInternalIp` | If using `hostNetwork=true`, setting `reportNodeInternalIp=true`, will pass the flag `report-node-internal-ip-address` to nginx-ingress. This sets the status of all Ingress objects to the internal IP address of all nodes running the NGINX Ingress controller.
`controller.electionID` | election ID to use for the status update | `ingress-controller-leader`
`controller.extraEnvs` | any additional environment variables to set in the pods | `{}`
`controller.extraContainers` | Sidecar containers to add to the controller pod. See [LemonLDAP::NG controller](https://github.com/lemonldap-ng-controller/lemonldap-ng-controller) as example | `{}`
`controller.extraVolumeMounts` | Additional volumeMounts to the controller main container | `{}`
`controller.extraVolumes` | Additional volumes to the controller pod | `{}`
`controller.extraInitContainers` | Containers, which are run before the app containers are started | `[]`
`controller.ingressClass` | name of the ingress class to route through this controller | `nginx`
`controller.scope.enabled` | limit the scope of the ingress controller | `false` (watch all namespaces)
`controller.scope.namespace` | namespace to watch for ingress | `""` (use the release namespace)
`controller.extraArgs` | Additional controller container arguments | `{}`
`controller.kind` | install as Deployment, DaemonSet or Both | `Deployment`
`controller.autoscaling.enabled` | If true, creates Horizontal Pod Autoscaler | false
`controller.autoscaling.minReplicas` | If autoscaling enabled, this field sets minimum replica count | `2`
`controller.autoscaling.maxReplicas` | If autoscaling enabled, this field sets maximum replica count | `11`
`controller.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage to scale | `"50"`
`controller.autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization percentage to scale | `"50"`
`controller.daemonset.useHostPort` | If `controller.kind` is `DaemonSet`, this will enable `hostPort` for TCP/80 and TCP/443 | false
`controller.daemonset.hostPorts.http` | If `controller.daemonset.useHostPort` is `true` and this is non-empty, it sets the hostPort | `"80"`
`controller.daemonset.hostPorts.https` | If `controller.daemonset.useHostPort` is `true` and this is non-empty, it sets the hostPort | `"443"`
`controller.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`controller.affinity` | node/pod affinities (requires Kubernetes >=1.6) | `{}`
`controller.terminationGracePeriodSeconds` | how many seconds to wait before terminating a pod | `60`
`controller.minReadySeconds` | how many seconds a pod needs to be ready before killing the next, during update | `0`
`controller.nodeSelector` | node labels for pod assignment | `{}`
`controller.podAnnotations` | annotations to be added to pods | `{}`
`controller.podLabels` | labels to add to the pod container metadata | `{}`
`controller.podSecurityContext` | Security context policies to add to the controller pod | `{}`
`controller.replicaCount` | desired number of controller pods | `1`
`controller.minAvailable` | minimum number of available controller pods for PodDisruptionBudget | `1`
`controller.resources` | controller pod resource requests & limits | `{}`
`controller.priorityClassName` | controller priorityClassName | `nil`
`controller.lifecycle` | controller pod lifecycle hooks | `{}`
`controller.service.annotations` | annotations for controller service | `{}`
`controller.service.labels` | labels for controller service | `{}`
`controller.publishService.enabled` | if true, the controller will set the endpoint records on the ingress objects to reflect those on the service | `false`
`controller.publishService.pathOverride` | override of the default publish-service name | `""`
`controller.service.enabled` | if disabled no service will be created. This is especially useful when `controller.kind` is set to `DaemonSet` and `controller.daemonset.useHostPorts` is `true` | true
`controller.service.clusterIP` | internal controller cluster service IP | `""`
`controller.service.omitClusterIP` | To omit the `clusterIP` from the controller service | `false`
`controller.service.externalIPs` | controller service external IP addresses. Do not set this when `controller.hostNetwork` is set to `true` and `kube-proxy` is used as there will be a port-conflict for port `80` | `[]`
`controller.service.externalTrafficPolicy` | If `controller.service.type` is `NodePort` or `LoadBalancer`, set this to `Local` to enable [source IP preservation](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typenodeport) | `"Cluster"`
`controller.service.healthCheckNodePort` | If `controller.service.type` is `NodePort` or `LoadBalancer` and `controller.service.externalTrafficPolicy` is set to `Local`, set this to [the managed health-check port the kube-proxy will expose](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typenodeport). If blank, a random port in the `NodePort` range will be assigned | `""`
`controller.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`controller.service.enableHttp` | if port 80 should be opened for service | `true`
`controller.service.enableHttps` | if port 443 should be opened for service | `true`
`controller.service.targetPorts.http` | Sets the targetPort that maps to the Ingress' port 80 | `80`
`controller.service.targetPorts.https` | Sets the targetPort that maps to the Ingress' port 443 | `443`
`controller.service.ports.http` | Sets service http port | `80`
`controller.service.ports.https` | Sets service https port | `443`
`controller.service.type` | type of controller service to create | `LoadBalancer`
`controller.service.nodePorts.http` | If `controller.service.type` is either `NodePort` or `LoadBalancer` and this is non-empty, it sets the nodePort that maps to the Ingress' port 80 | `""`
`controller.service.nodePorts.https` | If `controller.service.type` is either `NodePort` or `LoadBalancer` and this is non-empty, it sets the nodePort that maps to the Ingress' port 443 | `""`
`controller.service.nodePorts.tcp` | Sets the nodePort for an entry referenced by its key from `tcp` | `{}`
`controller.service.nodePorts.udp` | Sets the nodePort for an entry referenced by its key from `udp` | `{}`
`controller.livenessProbe.initialDelaySeconds` | Delay before liveness probe is initiated | 10
`controller.livenessProbe.periodSeconds` | How often to perform the probe | 10
`controller.livenessProbe.timeoutSeconds` | When the probe times out | 5
`controller.livenessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed. | 1
`controller.livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded. | 3
`controller.livenessProbe.port` | The port number that the liveness probe will listen on. | 10254
`controller.readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated | 10
`controller.readinessProbe.periodSeconds` | How often to perform the probe | 10
`controller.readinessProbe.timeoutSeconds` | When the probe times out | 1
`controller.readinessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed. | 1
`controller.readinessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded. | 3
`controller.readinessProbe.port` | The port number that the readiness probe will listen on. | 10254
`controller.metrics.enabled` | if `true`, enable Prometheus metrics | `false`
`controller.metrics.service.annotations` | annotations for Prometheus metrics service | `{}`
`controller.metrics.service.clusterIP` | cluster IP address to assign to service | `""`
`controller.metrics.service.omitClusterIP` | To omit the `clusterIP` from the metrics service | `false`
`controller.metrics.service.externalIPs` | Prometheus metrics service external IP addresses | `[]`
`controller.metrics.service.labels` | labels for metrics service | `{}`
`controller.metrics.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.metrics.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`controller.metrics.service.servicePort` | Prometheus metrics service port | `9913`
`controller.metrics.service.type` | type of Prometheus metrics service to create | `ClusterIP`
`controller.metrics.serviceMonitor.enabled` | Set this to `true` to create ServiceMonitor for Prometheus operator | `false`
`controller.metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus | `{}`
`controller.metrics.serviceMonitor.honorLabels` | honorLabels chooses the metric's labels on collisions with target labels. | `false`
`controller.metrics.serviceMonitor.namespace` | namespace where servicemonitor resource should be created | `the same namespace as nginx ingress`
`controller.metrics.serviceMonitor.scrapeInterval` | interval between Prometheus scraping | `30s`
`controller.metrics.prometheusRule.enabled` | Set this to `true` to create prometheusRules for Prometheus operator | `false`
`controller.metrics.prometheusRule.additionalLabels` | Additional labels that can be used so prometheusRules will be discovered by Prometheus | `{}`
`controller.metrics.prometheusRule.namespace` | namespace where prometheusRules resource should be created | `the same namespace as nginx ingress`
`controller.metrics.prometheusRule.rules` | [rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) to be prometheus in YAML format, check values for an example. | `[]`
`controller.admissionWebhooks.enabled` | Create Ingress admission webhooks. Validating webhook will check the ingress syntax. | `false`
`controller.admissionWebhooks.failurePolicy` | Failure policy for admission webhooks | `Fail`
`controller.admissionWebhooks.port` | Admission webhook port | `8080`
`controller.admissionWebhooks.service.annotations` | Annotations for admission webhook service | `{}`
`controller.admissionWebhooks.service.omitClusterIP` | To omit the `clusterIP` from the admission webhook service | `false`
`controller.admissionWebhooks.service.clusterIP` | cluster IP address to assign to admission webhook service | `""`
`controller.admissionWebhooks.service.externalIPs` | Admission webhook service external IP addresses | `[]`
`controller.admissionWebhooks.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.admissionWebhooks.service.loadBalancerSourceRanges` | List of IP CIDRs allowed access to load balancer (if supported) | `[]`
`controller.admissionWebhooks.service.servicePort` | Admission webhook service port | `443`
`controller.admissionWebhooks.service.type` | Type of admission webhook service to create | `ClusterIP`
`controller.admissionWebhooks.patch.enabled` | If true, will use a pre and post install hooks to generate a CA and certificate to use for the prometheus operator tls proxy, and patch the created webhooks with the CA. | `true`
`controller.admissionWebhooks.patch.image.repository` | Repository to use for the webhook integration jobs | `jettech/kube-webhook-certgen`
`controller.admissionWebhooks.patch.image.tag` |  Tag to use for the webhook integration jobs | `v1.0.0`
`controller.admissionWebhooks.patch.image.pullPolicy` | Image pull policy for the webhook integration jobs | `IfNotPresent`
`controller.admissionWebhooks.patch.priorityClassName` | Priority class for the webhook integration jobs | `""`
`controller.admissionWebhooks.patch.podAnnotations` | Annotations for the webhook job pods | `{}`
`controller.admissionWebhooks.patch.nodeSelector` | Node selector for running admission hook patch jobs | `{}`
`controller.customTemplate.configMapName` | configMap containing a custom nginx template | `""`
`controller.customTemplate.configMapKey` | configMap key containing the nginx template | `""`
`controller.addHeaders` | configMap key:value pairs containing [custom headers](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers) added before sending response to the client | `{}`
`controller.proxySetHeaders` | configMap key:value pairs containing [custom headers](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#proxy-set-headers) added before sending request to the backends| `{}`
`controller.headers` | DEPRECATED, Use `controller.proxySetHeaders` instead. | `{}`
`controller.updateStrategy` | allows setting of RollingUpdate strategy | `{}`
`controller.configMapNamespace` | The nginx-configmap namespace name | `""`
`controller.tcp.configMapNamespace` | The tcp-services-configmap namespace name | `""`
`controller.udp.configMapNamespace` | The udp-services-configmap namespace name | `""`
`defaultBackend.enabled` | Use default backend component | `true`
`defaultBackend.name` | name of the default backend component | `default-backend`
`defaultBackend.image.repository` | default backend container image repository | `k8s.gcr.io/defaultbackend-amd64`
`defaultBackend.image.tag` | default backend container image tag | `1.5`
`defaultBackend.image.pullPolicy` | default backend container image pull policy | `IfNotPresent`
`defaultBackend.image.runAsUser` | User ID of the controller process. Value depends on the Linux distribution used inside of the container image. By default uses nobody user. | `65534`
`defaultBackend.extraArgs` | Additional default backend container arguments | `{}`
`defaultBackend.extraEnvs` | any additional environment variables to set in the defaultBackend pods | `[]`
`defaultBackend.port` | Http port number | `8080`
`defaultBackend.livenessProbe.initialDelaySeconds` | Delay before liveness probe is initiated | 30
`defaultBackend.livenessProbe.periodSeconds` | How often to perform the probe | 10
`defaultBackend.livenessProbe.timeoutSeconds` | When the probe times out | 5
`defaultBackend.livenessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed. | 1
`defaultBackend.livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded. | 3
`defaultBackend.readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated | 0
`defaultBackend.readinessProbe.periodSeconds` | How often to perform the probe | 5
`defaultBackend.readinessProbe.timeoutSeconds` | When the probe times out | 5
`defaultBackend.readinessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed. | 1
`defaultBackend.readinessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded. | 6
`defaultBackend.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`defaultBackend.affinity` | node/pod affinities (requires Kubernetes >=1.6) | `{}`
`defaultBackend.nodeSelector` | node labels for pod assignment | `{}`
`defaultBackend.podAnnotations` | annotations to be added to pods | `{}`
`defaultBackend.podLabels` | labels to add to the pod container metadata | `{}`
`defaultBackend.replicaCount` | desired number of default backend pods | `1`
`defaultBackend.minAvailable` | minimum number of available default backend pods for PodDisruptionBudget | `1`
`defaultBackend.resources` | default backend pod resource requests & limits | `{}`
`defaultBackend.priorityClassName` | default backend  priorityClassName | `nil`
`defaultBackend.podSecurityContext` | Security context policies to add to the default backend | `{}`
`defaultBackend.service.annotations` | annotations for default backend service | `{}`
`defaultBackend.service.clusterIP` | internal default backend cluster service IP | `""`
`defaultBackend.service.omitClusterIP` | To omit the `clusterIP` from the default backend service | `false`
`defaultBackend.service.externalIPs` | default backend service external IP addresses | `[]`
`defaultBackend.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`defaultBackend.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`defaultBackend.service.type` | type of default backend service to create | `ClusterIP`
`imagePullSecrets` | name of Secret resource containing private registry credentials | `nil`
`rbac.create` | if `true`, create & use RBAC resources | `true`
`podSecurityPolicy.enabled` | if `true`, create & use Pod Security Policy resources | `false`
`serviceAccount.create` | if `true`, create a service account for the controller | `true`
`serviceAccount.name` | The name of the controller service account to use. If not set and `create` is `true`, a name is generated using the fullname template. | ``
`serviceAccount.backend.create` | if `true`, create a backend service account. Only useful if you need a pod security policy to run the backend. | `true`
`serviceAccount.backend.name` | The name of the backend service account to use. If not set and `create` is `true`, a name is generated using the fullname template. Only useful if you need a pod security policy to run the backend. | ``
`revisionHistoryLimit` | The number of old history to retain to allow rollback. | `10`
`tcp` | TCP service key:value pairs. The value is evaluated as a template. | `{}`
`udp` | UDP service key:value pairs The value is evaluated as a template. | `{}`

These parameters can be passed via Helm's `--set` option
```console
$ helm install stable/nginx-ingress --name my-release \
    --set controller.metrics.enabled=true
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install stable/nginx-ingress --name my-release -f values.yaml
```

A useful trick to debug issues with ingress is to increase the logLevel
as described [here](https://github.com/kubernetes/ingress-nginx/blob/master/docs/troubleshooting.md#debug)

```console
$ helm install stable/nginx-ingress --set controller.extraArgs.v=2
```
> **Tip**: You can use the default [values.yaml](values.yaml)

## PodDisruptionBudget

Note that the PodDisruptionBudget resource will only be defined if the replicaCount is greater than one,
else it would make it impossible to evacuate a node. See [gh issue #7127](https://github.com/helm/charts/issues/7127) for more info.

## Prometheus Metrics

The Nginx ingress controller can export Prometheus metrics.

```console
$ helm install stable/nginx-ingress --name my-release \
    --set controller.metrics.enabled=true
```

You can add Prometheus annotations to the metrics service using `controller.metrics.service.annotations`. Alternatively, if you use the Prometheus Operator, you can enable ServiceMonitor creation using `controller.metrics.serviceMonitor.enabled`.

## nginx-ingress nginx\_status page/stats server

Previous versions of this chart had a `controller.stats.*` configuration block, which is now obsolete due to the following changes in nginx ingress controller:
* in [0.16.1](https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0161), the vts (virtual host traffic status) dashboard was removed
* in [0.23.0](https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0230), the status page at port 18080 is now a unix socket webserver only available at localhost.
  You can use `curl --unix-socket /tmp/nginx-status-server.sock http://localhost/nginx_status` inside the controller container to access it locally, or use the snippet from [nginx-ingress changelog](https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md#0230) to re-enable the http server

## ExternalDNS Service configuration

Add an [ExternalDNS](https://github.com/kubernetes-incubator/external-dns) annotation to the LoadBalancer service:

```yaml
controller:
  service:
    annotations:
      external-dns.alpha.kubernetes.io/hostname: kubernetes-example.com.
```

## AWS L7 ELB with SSL Termination

Annotate the controller as shown in the [nginx-ingress l7 patch](https://github.com/kubernetes/ingress-nginx/blob/master/deploy/aws/l7/service-l7.yaml):

```yaml
controller:
  service:
    targetPorts:
      http: http
      https: http
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:XX-XXXX-X:XXXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
```

## AWS route53-mapper

To configure the LoadBalancer service with the [route53-mapper addon](https://github.com/kubernetes/kops/tree/master/addons/route53-mapper), add the `domainName` annotation and `dns` label:

```yaml
controller:
  service:
    labels:
      dns: "route53"
    annotations:
      domainName: "kubernetes-example.com"
```

## Ingress Admission Webhooks

With nginx-ingress-controller version 0.25+, the nginx ingress controller pod exposes an endpoint that will integrate with the `validatingwebhookconfiguration` Kubernetes feature to prevent bad ingress from being added to the cluster.

With nginx-ingress-controller in 0.25.* work only with kubernetes 1.14+, 0.26 fix [this issue](https://github.com/kubernetes/ingress-nginx/pull/4521)

## Helm error when upgrading: spec.clusterIP: Invalid value: ""

If you are upgrading this chart from a version between 0.31.0 and 1.2.2 then you may get an error like this:

```
Error: UPGRADE FAILED: Service "?????-controller" is invalid: spec.clusterIP: Invalid value: "": field is immutable
```

Detail of how and why are in [this issue](https://github.com/helm/charts/pull/13646) but to resolve this you can set `xxxx.service.omitClusterIP` to `true` where `xxxx` is the service referenced in the error.

