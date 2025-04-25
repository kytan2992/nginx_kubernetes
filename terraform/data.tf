data "aws_eks_cluster" "aws_eks_cluster" {
  name = var.aws_eks_cluster
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.aws_eks_cluster.name
}