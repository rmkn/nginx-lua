#!/bin/sh

service crond start

exec "$@"

