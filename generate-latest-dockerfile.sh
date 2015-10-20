#!/bin/bash
set -e

repos='armv7hf rpi i386'
nodeVersions='0.9.12 0.10.38 0.11.16 0.12.4 4.0.0'
resinUrl="http://resin-packages.s3.amazonaws.com/node/v\$NODE_VERSION/node-v\$NODE_VERSION-linux-#{TARGET_ARCH}.tar.gz"
nodejsUrl="http://nodejs.org/dist/v\$NODE_VERSION/node-v\$NODE_VERSION-linux-#{TARGET_ARCH}.tar.gz"

for repo in $repos; do
	case "$repo" in
	'rpi')
		binary_url=$resinUrl
		target_arch='armv6hf'
		baseImage='rpi-raspbian'
	;;
	'armv7hf')
		binary_url=$resinUrl
		target_arch='armv7hf'
		baseImage='armv7hf-debian'
	;;
	'i386')
		binary_url=$nodejsUrl
		target_arch='x86'
		baseImage='i386-debian'
	;;
	esac
	for nodeVersion in $nodeVersions; do
		echo $nodeVersion
		baseVersion=$(expr match "$nodeVersion" '\([0-9]*\.[0-9]*\)')
		dockerfilePath=$repo/$baseVersion
		mkdir -p $dockerfilePath
		sed -e s~#{FROM}~resin/$repo-buildpack-deps:jessie~g \
			-e s~#{BINARY_URL}~$binary_url~g \
			-e s~#{NODE_VERSION}~$nodeVersion~g \
			-e s~#{TARGET_ARCH}~$target_arch~g Dockerfile.tpl > $dockerfilePath/Dockerfile

		mkdir -p $dockerfilePath/onbuild
		sed -e s~#{FROM}~resin/$repo-node:$nodeVersion~g Dockerfile.onbuild.tpl > $dockerfilePath/onbuild/Dockerfile

		mkdir -p $dockerfilePath/slim
			sed -e s~#{FROM}~resin/$baseImage:jessie~g \
				-e s~#{BINARY_URL}~$binary_url~g \
				-e s~#{NODE_VERSION}~$nodeVersion~g \
				-e s~#{TARGET_ARCH}~$target_arch~g Dockerfile.slim.tpl > $dockerfilePath/slim/Dockerfile

		mkdir -p $dockerfilePath/wheezy
		sed -e s~#{FROM}~resin/$repo-buildpack-deps:wheezy~g \
			-e s~#{BINARY_URL}~$binary_url~g \
			-e s~#{NODE_VERSION}~$nodeVersion~g \
			-e s~#{TARGET_ARCH}~$target_arch~g Dockerfile.tpl > $dockerfilePath/wheezy/Dockerfile

		# Only for armv7hf-debian
		if [ $repo == "armv7hf" ]; then
			mkdir -p $dockerfilePath/sid
			sed -e s~#{FROM}~resin/$repo-buildpack-deps:sid~g \
				-e s~#{BINARY_URL}~$binary_url~g \
				-e s~#{NODE_VERSION}~$nodeVersion~g \
				-e s~#{TARGET_ARCH}~$target_arch~g Dockerfile.tpl > $dockerfilePath/sid/Dockerfile			
		fi
	done
done
