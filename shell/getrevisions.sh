#!/bin/bash
svn info -R $1 | egrep "^Path:|^Last Changed Rev:" | paste --
