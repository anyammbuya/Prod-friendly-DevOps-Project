#!/bin/bash

# Create the access entry for EC2 nodes
aws eks create-access-entry \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::<ACCOUNT ID>:role/kubectl-role \
  --type EC2

# Associate the auto node policy
aws eks associate-access-policy \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::<ACCOUNT ID>:role/kubectl-role \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy \
  --access-scope type=cluster
    