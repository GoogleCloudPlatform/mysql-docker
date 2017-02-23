#!/bin/bash -eu
#
# Copyright (C) 2017 Google Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#
# Required environment variables:
#   PROJECT: Your GCP project where the GCR bucket resides.
#   BUCKET: A GCS bucket (typically in the GCP project above) for
#     storing cloudbuild logs and intermediates.
#   KEYFILE: Absolute path to gcloud key file for authenticating your
#     service account. Make sure that the service account has write
#     access to your GCS (and GCR) buckets.
#   GCLOUD: Absolute path to gcloud binary, or a .tar.gz file
#     containing the gcloud application.
#   WORKINGDIR: Typically set to ".". This variable allows the script to
#     change to the correct working directory when executed in a different
#     build environment.

# Ensure all required env vars are supplied
for var in PROJECT BUCKET KEYFILE GCLOUD WORKINGDIR; do
  val=$(eval "echo \$$var")
  if [ -z "$val" ]; then
    echo "$var env variable is required"
    exit 1
  fi
done

cd "$WORKINGDIR"

if [[ "$GCLOUD" == *.tar.gz ]]; then
  # Extract the gcloud binary out of the tarball
  tar -xzf "$GCLOUD" -C .
  GCLOUD="google-cloud-sdk/bin/gcloud"
fi

# Setup auth and update gcloud
$GCLOUD auth activate-service-account --key-file=$KEYFILE
$GCLOUD config set project $PROJECT
$GCLOUD components install alpha -q
$GCLOUD components update -q

# Run the cloud build
$GCLOUD alpha container builds create . \
  --config=cloudbuild.yaml \
  --verbosity=info \
  --gcs-source-staging-dir="gs://$BUCKET/staging" \
  --gcs-log-dir="gs://$BUCKET/logs"
