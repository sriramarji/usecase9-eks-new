# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

# HELM Provider
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Install AWS Load Balancer Controller using HELM

# Resource: Helm Release 
resource "helm_release" "loadbalancer_controller" {
  depends_on = [var.lbc_iam_depends_on]            
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"     

  # Value changes based on your Region (Below is for us-east-1)
  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" 
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }       

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${var.lbc_iam_role_arn}"
  }

  set {
    name  = "vpcId"
    value = "${var.vpc_id}"
  }  

  set {
    name  = "region"
    value = "${var.aws_region}"
  }    

  set {
    name  = "clusterName"
    value = "${var.cluster_id}"
  }    
    
}


#resource "helm_release" "prometheus" {
#  name       = "prometheus"
#  repository = "https://prometheus-community.github.io/helm-charts"
#  chart      = "kube-prometheus-stack"
#  namespace  = "monitoring"
#  version    = "56.6.1" # Check for latest compatible version
#
#  create_namespace = true
#
#  set {
#    name  = "prometheus.service.type"
#    value = "LoadBalancer"
#  }
#
#  set {
#    name  = "grafana.enabled"
#    value = "true"
#  }
#
#  set {
#    name  = "grafana.service.type"
#    value = "LoadBalancer"
#  }
#}


data "helm_repository" "prometheus_community" {
  name = "prometheus-community"
  url  = "https://prometheus-community.github.io/helm-charts"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_grafana_stack" {
  name       = "kube-prometheus-stack"
  repository = data.helm_repository.prometheus_community.metadata[0].url
  chart      = "kube-prometheus-stack"
  version    = "58.0.0" # Pin version for stability
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [templatefile("${path.module}/values/prometheus-grafana-values.yaml", {
    lb_controller_name = helm_release.loadbalancer_controller.name
  })]

  depends_on = [
    helm_release.loadbalancer_controller,
    kubernetes_namespace.monitoring
  ]
}


# Resource: Kubernetes Ingress Class
#resource "kubernetes_ingress_class_v1" "ingress_class_default" {
#  depends_on = [helm_release.loadbalancer_controller]
#  metadata {
#    name = "my-aws-ingress-class"
#    annotations = {
#      "ingressclass.kubernetes.io/is-default-class" = "true"
#    }
#  }  
#  spec {
#    controller = "ingress.k8s.aws/alb"
#  }
#}