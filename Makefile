VERSION=0.0.20

usage:
	echo make dev

image:
	docker build -t sh19910711/homepage .
	docker build -t sh19910711/homepage:$(VERSION) .
	docker push sh19910711/homepage:$(VERSION)

prod:
	docker build -t sh19910711/homepage .
	docker run \
		--rm \
		--name homepage \
		-e AWS_REGION=us-east-1 \
		-e RACK_ENV=production \
		-e S3_BUCKET=hiroyuki.sano.ninja \
		-e S3_PREFIX=zeppelin/ \
		-v $(HOME)/.aws:/root/.aws \
		-p 8080:8080 \
		-ti \
		sh19910711/homepage

dev:
	docker build -t sh19910711/homepage:development -f Dockerfile.dev .
	docker run \
		--rm \
		--name homepage \
		-e AWS_REGION=us-east-1 \
		-e RACK_ENV=development \
		-e S3_BUCKET=hiroyuki.sano.ninja \
		-e S3_PREFIX=zeppelin/ \
		-v $(HOME)/.aws:/root/.aws \
		-v $(PWD):/wrk \
		-v $(HOME)/.w3m:/root/.w3m \
		-p $(PORT):8080 \
		-ti \
		sh19910711/homepage:development

.PHONY: spec
spec:
	docker exec homepage bundle exec rspec

.PHONY: admin
admin:
	docker exec -ti -e TERM=xterm homepage w3m http://localhost:8080/admin

zeppelin:
	docker run \
		--name zeppelin \
		--rm \
		-ti \
		-p 8080:8080 \
		-v $(HOME)/.aws:/root/.aws \
		-v /home/ec2-user/.ssh:/root/.ssh \
		-e ZEPPELIN_NOTEBOOK_STORAGE=org.apache.zeppelin.notebook.repo.S3NotebookRepo \
		-e ZEPPELIN_NOTEBOOK_S3_BUCKET=hiroyuki.sano.ninja \
		-e ZEPPELIN_NOTEBOOK_S3_USER=zeppelin \
		apache/zeppelin:0.8.0

/tmp/zeppelin:
	mkdir -p /tmp/zeppelin && \
		cd /tmp/zeppelin && \
		curl https://www-eu.apache.org/dist/zeppelin/zeppelin-0.8.0/zeppelin-0.8.0-bin-netinst.tgz | tar zxvf - && \
		/tmp/zeppelin/zeppelin-0.8.0-bin-netinst/bin/install-interpreter.sh --name md,shell,jdbc

zeppelin_gpu: /tmp/zeppelin
	ZEPPELIN_NOTEBOOK_STORAGE=org.apache.zeppelin.notebook.repo.S3NotebookRepo \
	ZEPPELIN_NOTEBOOK_S3_BUCKET=hiroyuki.sano.ninja \
	ZEPPELIN_NOTEBOOK_S3_USER=zeppelin \
	/tmp/zeppelin/zeppelin-0.8.0-bin-netinst/bin/zeppelin.sh

ec2:
	sudo yum install vim tmux docker
	sudo usermod -a -G docker ec2-user
	sudo service docker restart

console:
	docker exec -ti homepage bundle exec irb -r ./lib/note
