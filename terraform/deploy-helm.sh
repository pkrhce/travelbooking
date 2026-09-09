#!/bin/bash
set -e

echo "=== Connecting to GKE cluster ==="
gcloud container clusters get-credentials travelbooking-gke \
  --region us-central1 --project pk-sandbox-507311

echo "=== Installing ArgoCD ==="
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.service.type=LoadBalancer \
  --version 7.7.5 --wait

echo "=== Installing Prometheus + Grafana + Alertmanager ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.enabled=true \
  --set grafana.service.type=LoadBalancer \
  --set alertmanager.enabled=true \
  --version 65.1.0 --wait --timeout 10m

echo "=== Installing Falco (Runtime Security) ==="
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm upgrade --install falco falcosecurity/falco \
  --namespace falco --create-namespace \
  --set driver.kind=ebpf \
  --set falcosidekick.enabled=true --wait --timeout 5m

echo "=== Installing cert-manager ==="
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true --wait

echo "=== Installing Jaeger ==="
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace observability --create-namespace --wait --timeout 5m

echo "=== Installing OpenTelemetry Collector ==="
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --namespace observability --create-namespace \
  --set mode=daemonset --wait --timeout 5m

echo ""
echo "════════════════════════════════════════════"
echo "  ✅ ALL PLATFORM TOOLS INSTALLED!"
echo "════════════════════════════════════════════"
echo ""
echo "ArgoCD Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "ArgoCD URL:"
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ""
echo ""
echo "Grafana URL:"
kubectl -n monitoring get svc prometheus-grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ""
