#!/usr/bin/python

class FilterModule(object):
    '''Data related to filesystems for HANA VM'''

    def filters(self):
        return {
            'filesystemdata': self.filesystemdata
        }

    def filesystemdata(self, data_list):
        final_list = []
        data_map = data_list[0]
        sid = data_list[1]
        for k, v in data_map.items():
            key_to_check = 'lvm'
            if key_to_check in v:
                for m in v['lvm']['lv']:
                    temp_list = []
                    fs_device = "/dev/" + sid + "_" + v['lvm']['vg']['vg_name'] + "/" + sid + "_" + m['lv_name']
                    mp = None
                    fs_options = ""
                    label = ""
                    mount_source = fs_device
                    if m['lv_name'] == 'hana_data_lv':
                        label = "HANA_DATA"
                    elif m['lv_name'] == 'hana_log_lv':
                        label = "HANA_LOG"
                    elif m['lv_name'] == 'hana_shared_lv':
                        label = "HANA_SHARED"
                    else:
                        label = ""
                    if label != "":
                        fs_options = "-L " + label
                        mount_source = "LABEL=" + label
                    if "mount_point" in m.keys():
                        mp = m['mount_point']
                    fs_info = { "fs_device": fs_device, "fs_type": m['fs_type'], "mp": mp, "fs_options": fs_options, "mount_source": mount_source }
                    temp_list.append(fs_info)
                    final_list.append(temp_list)
            else:
                temp_list = []
                fs_device = v['device'][0] + "1"
                fs_options = ""
                label = ""
                mount_source = fs_device
                mp = None
                if "mount_point" in v.keys():
                    mp = v['mount_point']
                    if mp == "/hana/data":
                        label = "HANA_DATA"
                    elif mp == "/hana/log":
                        label = "HANA_LOG"
                    elif mp == "/hana/shared":
                        label = "HANA_SHARED"
                    else:
                        label = ""
                if label != "":
                    fs_options = "-L " + label
                    mount_source = "LABEL=" + label
                fs_info = { "fs_device": fs_device, "fs_type": v['fs_type'], "mp": mp, "fs_options": fs_options, "mount_source": mount_source }
                temp_list.append(fs_info)
                final_list.append(temp_list)
        return final_list
