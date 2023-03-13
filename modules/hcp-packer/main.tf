# data "hcp_packer_image" "hcp-packer-myapp" {
#   bucket_name     = "hcp-packer-myapp"
#   channel         = "latest"
#   cloud_provider  = "azure"
#   region          = "East US"
# }

# # Then replace your existing references with
# # data.hcp_packer_image.hcp-packer-myapp.cloud_image_id