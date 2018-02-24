# -*- coding: utf-8 -*-

import logging
import salt.utils
from salt.ext.six import iteritems as _iteritems

log = logging.getLogger(__name__)

def cleanup(name, **kwargs):
    ret = {'name': name, 'changes': {}, 'result': True, 'comment': ''}

    log.warning(__salt__['state.high']({}, test=True))
    # dirty = __salt__['track.list_dirty']()

    # if any(v for k, v in _iteritems(dirty)):
    #     ret['changes'] = dirty

    #     if __opts__['test']:
    #         ret['result'] = None
    #         ret['comment'] = '{0} would be changed to {1}'.format(name, 'expected state')
    #     else:
    #         success = __salt__['track.cleanup']()
    #         ret['result'] = success

    #         if success:
    #             ret['comment'] = '{0} changed to {1}'.format(name, 'expected state')
    #         else:
    #             ret['comment'] = '{0} failed while changing to {1}'.format(name, 'expected state')
    # else:
    #     ret['comment'] = '{0} is already in {1}'.format(name, 'expected state')

    return ret
