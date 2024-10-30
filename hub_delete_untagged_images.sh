#!/bin/bash

# Set needed variables from user input

read -p "Enter hub FQDN: " hub
read -p "Enter hub admin user: " hub_user
read -p "Enter hub admin user password: " hub_password
read -p "Enter hub Container registry name: " container_reg
echo

# Get the digest of image with tags set to latest (to skip later)
latest_tag_image=$(curl -s -k -u ${hub_user}:${hub_password} https://${hub}/api/galaxy/v3/plugin/execution-environments/repositories/${container_reg}/_content/images/ | jq -r '.data[] | select(.tags[]? == "latest") | .digest') 

[[ -z "$latest_tag_image" ]] && { echo "No images with latest tag"; exit 0; }

# Get all images and exclude the latest image tag
images_to_delete=$(curl -s -k -u ${hub_user}:${hub_password} https://${hub}/api/galaxy/v3/plugin/execution-environments/repositories/${container_reg}/_content/images/ | jq -r '.data[] | .digest' | grep -v $latest_tag_image)

# Exit if no images to delete
[[ -z "$images_to_delete" ]] && { echo "No images other than the tagged one to delete"; exit 0; }

# Delete all images except the latest
echo "Delete images from $container_reg local Container Registry:"
for digest in ${images_to_delete}
do
	curl -s -k -u ${hub_user}:${hub_password} -X DELETE https://${hub}/api/galaxy/v3/plugin/execution-environments/repositories/${container_reg}/_content/images/${digest}/
	echo
done

# show the current image
echo
echo "The current existing images with latest tag:"
curl -s -k -u ${hub_user}:${hub_password} https://${hub}/api/galaxy/v3/plugin/execution-environments/repositories/${container_reg}/_content/images/ | jq '{meta, data: [.data[] | del(.layers, .config_blob, .media_type, .schema_version, .image_manifests)]}'
