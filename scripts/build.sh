#!/bin/bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#!/usr/bin/env bash
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

if [ -z "$REGISTRY"]; then
  echo "ERROR: REGISTRY env variable required"
  exit 1
fi

if [ -z "$NAME"]; then
  echo "ERROR: NAME env variable required"
  exit 1
fi

if [ -z "$TAG"]; then
  echo "ERROR: TAG env variable required"
  exit 1
fi

if [ -z "$DOCKERFILE_DIR"]; then
  echo "ERROR: DOCKERFILE_DIR env variable required"
  exit 1
fi

if [ -z "$BUCKET"]; then
  echo "ERROR: BUCKET env variable required"
  exit 1
fi

if [ -z "$GCLOUD_CMD"]; then
  echo "ERROR: GCLOUD_CMD env variable required"
  exit 1
fi

envsubst <scripts/cloudbuild.yaml.in >cloudbuild.yaml
$GCLOUD_CMD alpha container builds create . --config=cloudbuild.yaml --verbosity=info --gcs-source-staging-dir="gs://$BUCKET/staging" --gcs-log-dir="gs://$BUCKET/logs"
