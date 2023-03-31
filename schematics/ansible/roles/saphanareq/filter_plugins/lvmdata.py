#!/usr/bin/python

class FilterModule(object):
    '''Data related to LVM for HANA VM'''

    def filters(self):
        return {
            'lvmdata': self.lvmdata
        }

    def lvmdata(self, data_map):
        final_list = []
        for k, v in data_map.items():
            key_to_check = 'lvm'
            if key_to_check in v:
                # In case the sum of the sizes of all LVs from the VG is lower than VG size 
                # and we don't want 'hana_data_lv' to be created as '100%FREE'
                lv100free = True
                total_lv_size = 0
                vgsize = 0
                for t in v['disk_size']:
                    vgsize += int(t)
                lvminfo = v['lvm']['lv']
                for n in lvminfo:
                    total_lv_size += int(n['lv_size'])
                if vgsize > total_lv_size:
                    lv100free = False
                for m in v['lvm']['lv']:
                    temp_list = []
                    lv_size = ""
                    # For HANA VMs, SWAP size is always 2 GB
                    # The volume group 'hana_vg' will always contain logical volume 'hana_data_lv'
                    if k == 'swap' or (k == 'hana_vg' and m['lv_name'] != 'hana_data_lv') or (lv100free == False and k == 'hana_vg' and m['lv_name'] == 'hana_data_lv'):
                        lv_size = m['lv_size'] + "G"
                    else:
                        lv_size = '100%FREE'
                    lvm_info = { "vg_name": v['lvm']['vg']['vg_name'], "lv_name": m['lv_name'], "lv_size": lv_size, "lv_stripes": m['lv_stripes'], "lv_stripe_size": m['lv_stripe_size'] }
                    temp_list.append(lvm_info)
                    final_list.append(temp_list)
        for i in range(len(final_list)):
            # LVM data 'hana_data_lv' should be last in array (in case it will be created in 'hana_vg') as we want 100%FREE as size
            if final_list[i][0]['vg_name'] == 'hana_vg' and final_list[i][0]['lv_name'] == 'hana_data_lv':
                final_list.append(final_list.pop(i))
                break
        return final_list
