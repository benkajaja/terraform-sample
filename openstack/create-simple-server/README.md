# Create simple server

## Info

This script would create resources below
* Instance
* Image (pull debian 9 image immediately)
* Network (attach to public network with given ID)
* Keypair (with given public key)
* Floating IP
* Security group (allow any inbound/outbound flow)

## Usage

1. Create `terraform.tfvars`
    ```ini
    username        = # OS_USERNAME
    tenantname      = # OS_TENANT_NAME or OS_PROJECT_NAME
    password        =
    authurl         = # OS_AUTH_URL
    region          = # OS_REGION_NAME
    imageID         = # If you want to use existing image, please give UUID of image
    pubkey          = "ssh-rsa ....."
    publicNetworkID = # UUID of public network
    ```
2. Run
    ```
    terraform apply
    ```
3. Destroy
   ```
   terraform destroy
   ```

## Tips

* Login account of Debian: `debian`
* Default port of Flask: `5000`

## Known issues

* Cannot use image resource
  * **Description**:
    With ubuntu server 16 or 18, instance would stuck "booting from Hard Disk" ...
      ```tf
      resource "openstack_images_image_v2" "myimage" {
        name             = "terraform_image"
        image_source_url = "http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64.img"
        container_format = "bare"
        disk_format      = "qcow2"
      }
      ```

  * **Solution**:
  Try to download image first, then use image ID in `main.tf`
      ```
      wget http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
      openstack image create "ubuntu16Server" --file ./xenial-server-cloudimg-amd64-disk1.img --disk-format qcow2 --container-format bare
      ```
