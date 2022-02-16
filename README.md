# Github Actions Runner

This is a docker image intended to be used with [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller)
and enhances the `summerwind/runner` image to propagate MTUs to networks created by the 
Github Actions runner.

The solution was originally described [here](https://github.com/actions-runner-controller/actions-runner-controller/issues/1046).

The docker image is available [here](https://hub.docker.com/repository/docker/tiagomelo/docker-actions-runner).

## Motivation

Despite the MTU being configurable with the dockerMTU setting on the Runner spec, it only
affects the default docker network and does not propagate to networks created by the Github
runner. This poses a problem when running workflows that use containers such as the 
`actions/checkout@v2` one.

## How it Works

This works by replacing the `docker` binary with a shim that sets the 
`com.docker.network.driver.mtu` option to whatever MTU is set on the docker `bridge` network
when a network is created. It effectively propagates the MTU to custom networks.


## Testing

At the moment there are no automated tests for this, but the solution can be validated as
follows:

**1. Create a Runner with the custom image**

```
---
apiVersion: actions.summerwind.dev/v1alpha1
kind: Runner
metadata:
  name: test-runner
spec:
  dockerEnabled: true
  dockerMTU: 1420
  image: tiagomelo/docker-actions-runner
  repository: <github-repository>
```

**2. Connect to the runner**

```
kubectl exec -it -c runner test-runner -- /bin/bash
```

**3. Test network connections within the runner**

```
docker network inspect bridge --format '{{index .Options "com.docker.network.driver.mtu"}}' 2>/dev/null
# returns 1420 (or whatever MTU is set)

docker run --rm rancher/curl https://github.com >/dev/null
# should complete

docker network create test

docker network inspect bridge --format '{{index .Options "com.docker.network.driver.mtu"}}' 2>/dev/null
# returns 1420 (or whatever MTU is set)

docker run --rm --network test rancher/curl https://github.com >/dev/null
# should complete

docker network rm test
```

## TODO

- Add Github Actions workflow to test and deploy the image

## Acknowledgements

- @FalconerTC for coming up with a [solution](https://github.com/actions-runner-controller/actions-runner-controller/issues/848#issuecomment-929394653)
- @lasse-aagren for the original [solution](https://github.com/actions/runner/issues/775#issuecomment-927826684)
