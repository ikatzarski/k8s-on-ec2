SHELL := /bin/bash

init:
	terraform init
	terraform validate

init-s3:
	test -n "$(ENVIRONMENT)"
	terraform init -reconfigure \
		-backend-config="bucket=k8s-tfstate" \
		-backend-config="key=${ENVIRONMENT}/terraform.tfstate" \
		-backend-config="region=eu-central-1" \
		-backend-config="dynamodb_table=k8s-tfstate"
		terraform validate 
	terraform validate

apply: init
	terraform plan -out=plan.out
	terraform apply plan.out

destroy: init
	terraform plan -destroy -out=plan.out
	terraform apply plan.out

get-private-key:
	rm -f ssh-key
	terraform output -raw private_key > ssh-key
	chmod 400 ssh-key

ssh-control-plane: get-private-key
	ssh -i ssh-key ubuntu@$$(terraform output -raw control_plane_public_ip)

regenerate-docs:
	terraform-docs markdown table --output-file README.md .
