build:
	docker build --tag tiagomelo/docker-actions-runner:latest .

push: build
	docker push tiagomelo/docker-actions-runner