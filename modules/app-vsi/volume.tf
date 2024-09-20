resource "ibm_is_volume" "vol" {

count = length( local.volume_sizes ) > 0 && length( local.volume_sizes ) == length( local.vol_profile ) ? length( local.volume_sizes ) : 0
  name		= "${var.HOSTNAME}-vol${count.index}"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= local.volume_sizes[count.index]
  profile	= local.vol_profile[count.index]
}
