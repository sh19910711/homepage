.PHONY: image
image:
	docker build -t homepage ./

.PHONY: server
server:
	docker run -ti -v $(PWD):/wrk -e PORT=8080 -p 8080:8080 homepage

.PHONY: gem
gem:
	docker run -v $(PWD):/wrk homepage bundle install -j4
	docker run -v $(PWD):/wrk homepage bundle update -j4