
STACK_VERSION := 7.15.0
ELASTICSEARCH_IMAGE := docker.elastic.co/elasticsearch/elasticsearch:$(STACK_VERSION)
TIMEOUT := 1200s

purge:
	kubectl delete secrets elastic-certificates elastic-certificate-pem elastic-certificate-crt|| true

pull-elasticsearch-image:
	docker pull $(ELASTICSEARCH_IMAGE)

secrets:
	docker rm -f elastic-helm-charts-certs || true
	rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12 || true
	docker run --name elastic-generate-certs -i -w /tmp \
		$(ELASTICSEARCH_IMAGE) \
		/bin/sh -c " \
			elasticsearch-certutil ca --out /tmp/elastic-stack-ca.p12 --pass '' && \
			elasticsearch-certutil cert --name es-master --dns es-master,es-master-headless --ca /tmp/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /tmp/elastic-certificates.p12" && \
	docker cp elastic-generate-certs:/tmp/elastic-certificates.p12 ./ && \
	docker rm -f elastic-generate-certs && \
	openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem && \
	openssl x509 -outform der -in elastic-certificate.pem -out elastic-certificate.crt 
	#kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 && \
	#kubectl create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem && \
	#kubectl create secret generic elastic-certificate-crt --from-file=elastic-certificate.crt && \
	#rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12
