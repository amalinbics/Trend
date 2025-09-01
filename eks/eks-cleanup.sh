#!/bin/bash

# Prompt for cluster name and region
read -p "Enter your EKS cluster name: " CLUSTER_NAME
read -p "Enter your AWS region (e.g., ap-south-1): " REGION

echo "🔍 Using cluster: $CLUSTER_NAME in region: $REGION"
echo "Starting cleanup..."

# Step 1: Delete all Kubernetes resources
echo "🧹 Deleting all Kubernetes resources..."
kubectl delete all --all --all-namespaces
kubectl delete pvc --all --all-namespaces
kubectl delete ingress --all --all-namespaces
kubectl delete configmap --all --all-namespaces
kubectl delete secret --all --all-namespaces
echo "✅ Kubernetes resources deleted."

# Step 2: Delete node groups
echo "🧼 Deleting node groups..."
NODEGROUPS=$(eksctl get nodegroup --cluster $CLUSTER_NAME --region $REGION -o json | jq -r '.[].Name')
for NG in $NODEGROUPS; do
  echo "Deleting node group: $NG"
  eksctl delete nodegroup --cluster $CLUSTER_NAME --name $NG --region $REGION
done

# Step 3: Delete Fargate profiles
echo "🧼 Deleting Fargate profiles..."
FARGATE_PROFILES=$(aws eks list-fargate-profiles --cluster-name $CLUSTER_NAME --region $REGION --output text --query 'fargateProfileNames')
for FP in $FARGATE_PROFILES; do
  echo "Deleting Fargate profile: $FP"
  aws eks delete-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FP --region $REGION
done

# Step 4: Delete the EKS cluster
echo "🧨 Deleting EKS cluster: $CLUSTER_NAME"
eksctl delete cluster --name $CLUSTER_NAME --region $REGION
echo "✅ Cluster deleted."

# Step 5: List leftover AWS resources
echo "🧹 Listing leftover AWS resources..."

echo "🔗 Load Balancers:"
aws elb describe-load-balancers --region $REGION --query 'LoadBalancerDescriptions[*].DNSName' --output table
aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[*].DNSName' --output table

echo "💾 Unattached EBS Volumes:"
aws ec2 describe-volumes --filters Name=status,Values=available --region $REGION --query 'Volumes[*].VolumeId' --output table

echo "🛡️ Security Groups:"
aws ec2 describe-security-groups --region $REGION --query 'SecurityGroups[*].GroupId' --output table

echo "📦 CloudFormation Stacks:"
aws cloudformation describe-stacks --region $REGION --query 'Stacks[*].StackName' --output table

echo "✅ Cleanup complete. Review and manually delete leftover resources if needed."