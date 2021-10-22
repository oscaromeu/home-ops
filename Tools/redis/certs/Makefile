DOMAIN='*.localhost'

ca_key:
	openssl genrsa -out rootCA.key 4096
ca_crt:
	openssl req -x509 -new -nodes -key rootCA.key  -subj "/C=ES/ST=Barcelona/O=Monitoring/CN=localhost" -sha256 -days 1024 -out rootCA.crt

redis_key:
	openssl genrsa -out redis.key 2048

redis_csr:
	openssl req -new -sha256 -key redis.key -subj "/C=ES/ST=Barcelona/O=Monitoring/CN=$(DOMAIN)" -out $(DOMAIN).csr

redis_crt:
	openssl x509 -req -in $(DOMAIN).csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out redis.crt -days 3650 -sha256

all: ca_key ca_crt redis_key redis_csr redis_crt

redis: redis_key redis_csr redis_crt
