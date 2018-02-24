# -*- coding: utf-8 -*-

import logging
import salt.utils
from salt.ext.six import iteritems as _iteritems

log = logging.getLogger(__name__)

# TODO: see if we can track this via grains instead...
def etc_files():
    return '/etc/config/track-files'

def cleanup():
    dirty = list_dirty()

    for file in dirty['files']:
        # TODO: delete...
        pass

    return True

def list_dirty():
    ret = {
        'files': [],
    }

    # files
    try:
        with open(etc_files()) as f:
            for line in f.readlines():
                file = line.strip()
                if _is_file_dirty(file):
                    ret['files'].append(file)
    except IOError as e:
        log.debug(e)

    return ret

def _is_file_dirty(file):
    # TODO:
    _gen_keep_files()
    return True

def _get_states_lows(state):
    log.error(__lowstate__)
    return [l for l in __lowstate__ if l['state'] == state]

def _gen_keep_files():
    # get lows
    all_lows = _get_states_lows('iptables')
    # lows = [l for l in all_lows if l.get('save', False)]

    # # go through each existing rule
    # for table, chains in current_state.items():
    #     for chain_name, chain in chains.items():
    #         for rule in chain['rules']:
    #             common_rule = _get_common_current_state(rule, table, chain_name)

    #             # check if it's in the lowstate
    #             hasRule = False
    #             for low in lows:
    #                 common_low = _get_common_low(low)

    #                 # log.warning('common_low')
    #                 # log.warning(json.dumps(common_low))

    #                 if common_rule == common_low:
    #                     hasRule = True
    #                     break
    #             if not hasRule:

    #                 # log.warning('common_rule')
    #                 # log.warning(json.dumps(common_rule))

    #                 # delete rule
    #                 csv_rule = {}
    #                 for k, v in common_rule.items():
    #                     if k in ['table', 'chain']:
    #                         continue

    #                     if isinstance(v, list):
    #                         csv_rule[k] = ",".join(v)
    #                     else:
    #                         csv_rule[k] = v
    #                 rule_str = __salt__['iptables.build_rule'](
    #                     table=table,
    #                     chain=chain_name,
    #                     family=family, **csv_rule
    #                 )
    #                 res = __salt__['iptables.delete'](
    #                     table,
    #                     chain=chain_name,
    #                     rule=rule_str,
    #                     family=family,
    #                 )
    #                 # # ret['changes']['deleted'] += [rule]
    #                 # # ret['changes']['deleted'] += [__salt__['iptables.build_rule'](family=family, **rule)]
    #                 # ret['changes']['deleted'] += [res]

    #                 ret['changes']['deleted'] += [rule_str]
