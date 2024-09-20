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
            if 'lvm' in v.keys():
                for m in v['lvm']['lv']:
                    temp_list = []
                    lv_size = ""
                    if '%' not in m['lv_size']:
                        lv_size = m['lv_size'] + "G"
                    else:
                        lv_size = m['lv_size']
                    lv_options = ""
                    if "raid_type" in m.keys():
                        lv_options = "--type " + m['raid_type']
                    if  "mirrors" in m.keys():
                        lv_options += " -m " + m['mirrors']
                    if "lv_stripes" in m.keys():
                        lv_options += " -i " + m['lv_stripes']
                        if "lv_stripe_size" in m.keys():
                            lv_options += " -I " + m['lv_stripe_size']
                    lvm_info = { "vg_name": v['lvm']['vg']['vg_name'], "lv_name": m['lv_name'], "lv_size": lv_size, "lv_options": lv_options }
                    temp_list.append(lvm_info)
                    final_list.append(temp_list)
        for i in range(len(final_list)):
            # LVM data 'hana_data_lv' should be last in array (in case it will be created in 'hana_vg') as we want 100%FREE as size
            if final_list[i][0]['lv_name'] == 'hana_data_lv':
                final_list.append(final_list.pop(i))
                break
        return final_list
