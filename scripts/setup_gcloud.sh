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

# This script downloads, installs, and configures gcloud:
# - Downlaods the latest version of gcloud.
# - Installs gcloud at $PWD/google-cloud-sdk/bin/gcloud
# - Authenticates using a service account JSON keyfile.
# - Configures the default project

set -e
set -x

if [ -z "$PROJECT"]; then
  echo "ERROR: PROJECT env variable required"
  exit 1
fi

if [ -z "$KEYFILE"]; then
  echo "ERROR: KEYFILE env variable required"
  exit 1
fi


wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
tar -xzf google-cloud-sdk.tar.gz
google-cloud-sdk/install.sh --usage-reporting=false --path-update=false --command-completion=false

# Setup auth and update gcloud
google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=$KEYFILE
google-cloud-sdk/bin/gcloud config set project $PROJECT
google-cloud-sdk/bin/gcloud components install alpha -q
google-cloud-sdk/bin/gcloud components update -q
