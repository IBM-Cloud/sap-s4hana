#!/usr/bin/python

import decimal
import re

class FilterModule(object):
    '''Storage details from profile containing also the devices for HANA VM'''

    def filters(self):
        return {
            'storagedetails': self.storagedetails
        }

    def storagedetails(self, data_list):
        # data_list[0] - json file data
        # data_list[1] - ansible_devices data
        # data_list[2] - selected storage profile
        json_file_data = data_list[0]
        ansible_devices_data = data_list[1]
        hana_profile = data_list[2]

        storage_profile_info = json_file_data['profiles'][hana_profile]['storage']

        # Create a sorted list with all disks device keys available on the VM
        pattern = 'dm-'
        all_disk_device_keys = sorted([item for item in ansible_devices_data if re.match(pattern, item) == None])

        # Get the number of the disks to be configured
        necessary_disks_number = ""
        count_disks = 0
        for k, v in storage_profile_info.items():
            count_disks += int(v['disk_count'])
        necessary_disks_number = str(count_disks)

        # Get a list with the device keys for disks to be configured
        N = int(necessary_disks_number)
        disk_device_keys = all_disk_device_keys[-N:]

        # Get a list with the provisioned disk sizes corresponding to the device keys for disks to be configured
        size_provisioned_disks = []
        for m, n in ansible_devices_data.items():
            if m in disk_device_keys and 'KB' not in n['size']:
                size_provisioned_disks.append(n['size'])

        # Sort the list with provisioned disk sizes
        size_provisioned_disks_sorted = sorted(size_provisioned_disks)

        # Get a list of disk sizes corresponding to the selected profile
        size_profile_disks = []
        for k, v in storage_profile_info.items():
            display_size = ""
            if int(v['disk_size']) >= 1024:
                rounded_val = round(decimal.Decimal(int(v['disk_size']) / 1024), 2)
                no_decimal_places = abs(rounded_val.as_tuple().exponent)
                if no_decimal_places == 0:
                    display_size = str(rounded_val) + ".00 TB"
                elif no_decimal_places == 1:
                    display_size = str(rounded_val) + "0 TB"
                elif no_decimal_places == 2:
                    display_size = str(rounded_val) + " TB"
            else:
                display_size = v['disk_size'] + ".00 GB"
            for t in range(int(v['disk_count'])):     
                size_profile_disks.append(display_size)

        # Sort the list with disk sizes from profile
        size_profile_disks_sorted = sorted(size_profile_disks)

        # Get the missing disks
        if (len(list(set(size_profile_disks_sorted) - set(size_provisioned_disks_sorted))) > 0) or (len(size_profile_disks_sorted) != len(size_provisioned_disks_sorted)):
            msg = "The disks required for profile '" +  hana_profile + "' are missing. The following disks sizes are required: " + str(size_profile_disks_sorted)[1:-1] + ". The following disk sizes were deployed: " + str(size_provisioned_disks_sorted)[1:-1]
            return msg
        else:
            temp_list = []
            for k, v in storage_profile_info.items():
                new_list1 = []
                new_list2 = []
                display_size = ""
                if int(v['disk_size']) >= 1024:
                    rounded_val = round(decimal.Decimal(int(v['disk_size']) / 1024), 2)
                    no_decimal_places = abs(rounded_val.as_tuple().exponent)
                    if no_decimal_places == 0:
                        display_size = str(rounded_val) + ".00 TB"
                    elif no_decimal_places == 1:
                        display_size = str(rounded_val) + "0 TB"
                    elif no_decimal_places == 2:
                        display_size = str(rounded_val) + " TB"
                else:
                    display_size = v['disk_size'] + ".00 GB"
                for t in range(int(v['disk_count'])):
                    new_list1.append(v['disk_size'])
                    for m, n in ansible_devices_data.items():
                        if (n['size'] == display_size) and (m in disk_device_keys) and (m not in temp_list):
                            new_list2.append("/dev/" + m)
                            temp_list.append(m)
                            break
                storage_profile_info[k]['disk_size'] = new_list1
                storage_profile_info[k]['device'] = new_list2
                final_storage = storage_profile_info
            return final_storage
