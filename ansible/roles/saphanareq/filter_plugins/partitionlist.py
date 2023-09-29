#!/usr/bin/python

class FilterModule(object):
    '''List of devices for partitions on HANA VM'''

    def filters(self):
        return {
            'partitionlist': self.partitionlist
        }

    def partitionlist(self, data_map):
        final_list = []
        for k, v in data_map.items():
            key_to_check = 'lvm'
            if key_to_check not in v:
                final_list.append(v['device'])
        return final_list
