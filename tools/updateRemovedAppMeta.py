#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Andreas Itzchak Rehberg <izzysoft@qumran.org>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Reads the YAML for an app-to-be-added from STDIN, adjusts AppRemoved,
# then outputs the resulting YAML to STDOUT
# Usage: $0 < infile.yml > outfile.yml

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
if "AppRemoved" in meta["MaintainerNotes"]:
  meta["MaintainerNotes"]["AppRemoved"] = date.today()
else:
  meta["MaintainerNotes"].insert(1, "AppRemoved", date.today())   # type is CommentedMap, a special dict, so insert takes position, name, value

# dump resulting YAML
yaml.dump(meta, sys.stdout)
