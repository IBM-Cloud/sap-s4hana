resource "ibm_is_volume" "vol" {
  count = length( local.VOLUME_SIZES ) > 0 && length( local.VOLUME_SIZES ) == length( local.VOL_PROFILE ) ? length( local.VOLUME_SIZES ) : 0
  name		= "${var.HOSTNAME}-vol${count.index}"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= local.VOLUME_SIZES[count.index]
  profile	= local.VOL_PROFILE[count.index]
}
