VERSION=0.1.0

.PHONY: image push prod dev spec admin zeppelin ec2 console

build:
	docker build -t sh19910711/homepage .
	docker tag sh19910711/homepage sh19910711/homepage:$(VERSION)

	cd docker/mysql && \
		docker build -t sh19910711/homepage_database . && \
		docker tag sh19910711/homepage_database sh19910711/homepage_database:$(VERSION)

	cd docker/search && \
		docker build -t sh19910711/homepage_search . && \
		docker tag sh19910711/homepage_search sh19910711/homepage_search:$(VERSION)

	cd docker/commands && \
		docker build -t sh19910711/homepage_commands . && \
		docker tag sh19910711/homepage_commands sh19910711/homepage_commands:$(VERSION)

push: build
	docker push sh19910711/homepage:$(VERSION)
	docker push sh19910711/homepage_database:$(VERSION)
	docker push sh19910711/homepage_search:$(VERSION)
	docker push sh19910711/homepage_commands:$(VERSION)

/usr/local/bin/docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

dev: build /usr/local/bin/docker-compose
	VERSION=$(VERSION) docker-compose up

dev/mysql/dump:
	mysqldump -h database.homepage2 -uroot -pmysql homepage | gzip - | aws s3 cp - s3://hiroyuki.sano.ninja/tmp/mysql/dump.sql.gz

dev/mysql/restore:
	aws s3 cp s3://hiroyuki.sano.ninja/tmp/mysql/dump.sql.gz - | zcat | docker-compose exec -T database mysql -pmysql homepage
	echo "grant select, update on homepage.* to homepage@'%';" | docker-compose exec -T database mysql -pmysql

dev/search/restore:
	aws s3 cp s3://hiroyuki.sano.ninja/tmp/search/init_search.bash - | docker-compose exec -T search bash

.PHONY: spec spec/all
spec:
	docker exec -e DATABASE_USERNAME -e DATABASE_PASSWORD homepage bundle exec rspec -t ~e2e

spec/all:
	docker exec -e DATABASE_USERNAME -e DATABASE_PASSWORD homepage bundle exec rspec

setup/amazonlinux:
	sudo yum install vim tmux docker
	sudo usermod -a -G docker ec2-user
	sudo service docker restart
