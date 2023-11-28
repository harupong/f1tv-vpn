resource "oci_core_instance" "ubuntu_instance" {
    # Required
    count = var.instance_count

    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = var.compartment_id
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        source_id = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaj54obnpdo6hzhs4p7x2sj4g2iuldtqqklov6dnilpddzo26myqoa"
        source_type = "image"
    }

    # Optional
    display_name = "main-oci-${count.index}"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = var.subnet_id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_authorized_keys)
        user_data = "${base64encode(
            templatefile("../../modules/lightsail_vpn/user_data.sh", {
                tailscale_api_key = var.tailscale_api_key,
                name = "main-oci-${count.index}"}
        ))}"
    } 
    preserve_boot_volume = false
}