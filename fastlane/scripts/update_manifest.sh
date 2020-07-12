#!/bin/bash +x

version=$1
user=$2
email=$3
path=$4

tmp_file=$(mktemp)

keys=(
	".dependency_version = \"${version}\" |"
	".manifest_version = \"${version}\" |"
	".author_email = \"${email}\" |"
	".author_name = \"${user}\""
)

jq "${keys[*]}" "${path}" > "${tmp_file}" && mv "${tmp_file}" "${path}"
