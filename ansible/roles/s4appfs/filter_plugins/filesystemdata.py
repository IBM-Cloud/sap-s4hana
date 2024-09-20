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
                    mount_opt = "defaults"
                    mount_source = fs_device
                    if "label" in m.keys():
                        fs_options = "-L " + m['label']
                        mount_source = "LABEL=" + m['label']
                    if "fs_create_options" in m.keys():
                        fs_options = fs_options + " " + m['fs_create_options']
                    if "mount_point" in m.keys():
                        mp = m['mount_point']
                    if "mount_options" in m.keys():
                        mount_opt = m['mount_options']
                    fs_info = { "fs_device": fs_device, "fs_type": m['fs_type'], "mp": mp, "fs_options": fs_options, "mount_source": mount_source, "mount_opt": mount_opt }
                    temp_list.append(fs_info)
                    final_list.append(temp_list)
            else:
                temp_list = []
                fs_device = v['device'][0] + "1"
                fs_options = ""
                mount_opt = ""
                mount_source = fs_device
                mp = None
                if "label" in v.keys():
                    fs_options = "-L " + v['label']
                    mount_source = "LABEL=" + v['label']
                if "fs_create_options" in v.keys():
                    fs_options = fs_options + " " + v['fs_create_options']
                if "mount_point" in v.keys():
                    mp = v['mount_point']
                if "mount_options" in v.keys():
                    mount_opt = v['mount_options']
                fs_info = { "fs_device": fs_device, "fs_type": v['fs_type'], "mp": mp, "fs_options": fs_options, "mount_source": mount_source, "mount_opt": mount_opt }
                temp_list.append(fs_info)
                final_list.append(temp_list)
        return final_list
