#!/bin/bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT=$(dirname $(dirname $(realpath "$0")))
else
	ROOT=$(dirname $(dirname $(readlink -f $0)))
fi

cd $ROOT

# Node modules
test -d node_modules || ./scripts/npm.sh install

# Get electron
if [[ "$OSTYPE" == "darwin"* ]]; then
	test -d .build/electron/Code\ -\ OSS.app || ./node_modules/.bin/gulp electron
else
	test -d .build/electron/code-oss || ./node_modules/.bin/gulp electron
fi

# Build
test -d out || ./node_modules/.bin/gulp compile

# Unit Tests
if [[ "$OSTYPE" == "darwin"* ]]; then
	cd $ROOT ; ulimit -n 4096 ; ATOM_SHELL_INTERNAL_RUN_AS_NODE=1 \
		./.build/electron/Code\ -\ OSS.app/Contents/MacOS/Electron \
		node_modules/mocha/bin/_mocha $*
else
	cd $ROOT ; ATOM_SHELL_INTERNAL_RUN_AS_NODE=1 \
		./.build/electron/code-oss \
		node_modules/mocha/bin/_mocha $*
fi
