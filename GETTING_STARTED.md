# Getting started

## Prerequisites
- MacOSX-10.9
- Python2.7

To set up ansible, terraform and PATH
```
$ make ansible terraform
$ . .env
```

## AWS
```
$ VAR_FILE=~/.aws/your-tf.tfvars make plan
$ VAR_FILE=~/.aws/your-tf.tfvars make apply
$ IDENTITY_FILE=~/.ssh/your.pem make aws-ssh-config
$ make playbook
```

## Vagrant
```
$ vagrant up
$ make natpf
$ make playbook
...
$ open http://localhost:8080/
```

