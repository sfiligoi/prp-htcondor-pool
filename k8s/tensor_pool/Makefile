.PHONY: secret_pool

all: secret_pool

secret_pool:
	-kubectl delete secret condor-poolpassswd -n isfiligoi
	kubectl create secret generic condor-poolpassswd -n isfiligoi --from-file=poolpasswd

