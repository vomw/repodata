#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Andreas Itzchak Rehberg <izzysoft@qumran.org>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Reads the YAML for an app-to-be-added from STDIN, adjusts AppRemoved,
# then outputs the resulting YAML to STDOUT
#
# Usage: updateRemovedAppMeta.py [reason] < infile.yml > outfile.yml
#        cat infile.yml | updateRemovedAppMeta.py [reason] > outfile.yml
# if no reason is specified, it is extracted from the last entry of MaintainerNotes.Status

import sys
from ruamel.yaml import YAML
from datetime import date

# define our YAML settings
yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.width = 4096           # prevent long lines from being wrapped
yaml.preserve_quotes = True # do not convert double-quotes to single-quotes

# read the input YAML
meta = yaml.load(sys.stdin)

# ensure AppAdded is set (at the start of MaintainerNotes)
#removed_log = f'{datetime.now():%Y-%m-%d} ' + sys.argv[1]
try:
  reason = sys.argv[1]
except:
  if "Status" in meta["MaintainerNotes"]:
    reason = meta["MaintainerNotes"]["Status"][-1].partition(' ')[2]
  else:
    reason = f'see status'
if "AppRemoved" in meta["MaintainerNotes"]:
  meta["MaintainerNotes"]["AppRemoved"] = f'{date.today()} {reason}'
else:
  meta["MaintainerNotes"].insert(1, "AppRemoved", f'{date.today()} {reason}')   # type is CommentedMap, a special dict, so insert takes position, name, value

# dump resulting YAML
yaml.dump(meta, sys.stdout)
