# ─────────────────────────────────────────────
# Helm Releases — Platform Tools on GKE
# ─────────────────────────────────────────────

# ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.5"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [google_container_node_pool.primary]
}

# Prometheus + Grafana + Alertmanager (kube-prometheus-stack)
resource "helm_release" "prometheus_stack" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "65.1.0"

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.enabled"
    value = "true"
  }

  depends_on = [google_container_node_pool.primary]
}

# Falco (Runtime Security)
resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  namespace        = "falco"
  create_namespace = true

  set {
    name  = "driver.kind"
    value = "ebpf"
  }

  set {
    name  = "falcosidekick.enabled"
    value = "true"
  }

  depends_on = [google_container_node_pool.primary]
}

# OpenTelemetry Collector
resource "helm_release" "otel_collector" {
  name             = "otel-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  namespace        = "observability"
  create_namespace = true

  values = [<<-EOT
    mode: daemonset
    config:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318
      exporters:
        otlp:
          endpoint: "jaeger-collector.observability.svc.cluster.local:4317"
          tls:
            insecure: true
        prometheus:
          endpoint: "0.0.0.0:8889"
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [otlp]
          metrics:
            receivers: [otlp]
            exporters: [prometheus]
  EOT
  ]

  depends_on = [google_container_node_pool.primary]
}

# Jaeger
resource "helm_release" "jaeger" {
  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = "observability"
  create_namespace = true

  set {
    name  = "collector.service.otlp.grpc.name"
    value = "otlp-grpc"
  }

  set {
    name  = "collector.service.otlp.http.name"
    value = "otlp-http"
  }

  depends_on = [google_container_node_pool.primary]
}

# cert-manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [google_container_node_pool.primary]
}
