playbook: ssh-config
	ansible-playbook -i hosts playbook.yaml

ssh:
	ssh -F ssh-config default

ssh-config:
	vagrant ssh-config > ssh-config

## Vagrant
natpf:
	VBoxManage controlvm "ansible-jenkins" natpf1 ",tcp,127.0.0.1,8080,,8080"

# Clean up
clean:
	rm ssh-config
clean_natpf:
	VBoxManage controlvm "ansible-jenkins" natpf1 delete tcp_8080_8080
distclean: clean clean_natpf
	rm -rf .e symlink.jenkins

## AWS
aws-ssh-config: ssh-config.sh
	./ssh-config.sh \
		`./bin/terraform output public_ip.ci-master` \
		$(IDENTITY_FILE) > ssh-config

tf_opts=-var-file $(VAR_FILE) \
         -var cidr_office="113.35.164.177/32" \
         -var cidr_github="192.30.252.0/22"
plan:
	./bin/terraform plan $(tf_opts)
apply:
	./bin/terraform apply $(tf_opts)
show:
	./bin/terraform show terraform.tfstate
destroy: destroy.tfplan
	./bin/terraform apply destroy.tfplan
destroy.tfplan:
	./bin/terraform plan -destroy -out destroy.tfplan $(tf_opts)

# Install terraform
terraform: bin/terraform
bin/terraform: bin/terraform_0.2.2_darwin_amd64.zip
	(cd bin; unzip terraform_0.2.2_darwin_amd64.zip)
bin/terraform_0.2.2_darwin_amd64.zip:
	(mkdir -p bin; cd bin; curl -OL https://dl.bintray.com/mitchellh/terraform/terraform_0.2.2_darwin_amd64.zip)

# Install ansible
ansible: .e/bin/ansible
.e/bin/ansible: .e
	.e/bin/pip2.7 install ansible
.e/bin/aws: .e
	.e/bin/pip2.7 install awscli
.e:
	virtualenv .e

