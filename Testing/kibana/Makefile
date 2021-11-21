
STACK_VERSION := 7.15.0
ELASTICSEARCH_IMAGE := docker.elastic.co/elasticsearch/elasticsearch:$(STACK_VERSION)
TIMEOUT := 1200s

purge:
	kubectl delete secrets kibana-certificates kibana-certificate-pem kibana-certificate-crt|| true

pull-elasticsearch-image:
	docker pull $(ELASTICSEARCH_IMAGE)

secrets:
	#docker rm -f kibana-helm-charts-certs || true
	#rm -f kibana-certificates.p12 kibana-certificate.pem kibana-certificate.crt kibana-stack.p12 || true
	docker run --name kibana-generate-certs -i -w /tmp \
		$(ELASTICSEARCH_IMAGE) \
		/bin/sh -c " \
			elasticsearch-certutil ca --out /tmp/kibana-stack.p12 --pass '' && \
			elasticsearch-certutil cert --name security-master --dns security-master --ca /tmp/kibana-stack.p12 --pass '' --ca-pass '' --out /tmp/kibana-certificates.p12" && \
	docker cp kibana-generate-certs:/tmp/kibana-certificates.p12 ./ && \
	docker rm -f kibana-generate-certs && \
	openssl pkcs12 -nodes -passin pass:'' -in kibana-certificates.p12 -out kibana-certificate.pem && \
	openssl x509 -outform der -in kibana-certificate.pem -out kibana-certificate.crt
	#kubectl create secret generic kibana-certificates --from-file=kibana-certificates.p12 && \
	#kubectl create secret generic kibana-certificate-pem --from-file=kibana-certificate.pem && \
	#kubectl create secret generic kibana-certificate-crt --from-file=kibana-certificate.crt && \
	#rm -f kibana-certificates.p12 kibana-certificate.pem kibana-certificate.crt kibana-stack.p12
