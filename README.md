# Enterprise Linux From Scratch v0.1

## What is ELFS?
ELFS is a guide on how to build Enterprise Linux from scratch! Right now we use Rocky Linux sources for the build, but the plan is to use OpenELA sources when they release.

## Purpose
The purpose of ELFS is to be an educational resource for those looking to get into Enterprise Linux development. ELFS is also meant to fill the gap for hobbyists/hackers alike who want to build their own Enterprise Linux distribution for fun and learning how Enterprise Linux is put together!

## Notes
~~At this time there are only build notes available which give a rough outline for the guide. Several Mock configs and patches are provided aswell alongside elfs.sh to aid in the build process. elfs.sh Provides helper functions and utilities for those who would like to use them. Right now it is best to source elfs.sh in a Bash terminal to get the ELFS variable.~~

There are now refined build notes available in extranotes. They give an outline of the guide and explain parts of the build process better. buildnotes has been updated to include any changes that were made during the refining process.

At this time only the Core group build process is documented.

IMPORTANT: You must change the baseurl=file:/// repository path in the Mock configs to point towards your $ELFS/localrepo/tmp and $ELFS/localrepo/results paths! This must be changed for the ELFS repositories defined in the configuration files. By default they point to /home/maxinehayes90/elfs/localrepo/tmp and /home/maxinehayes90/elfs/localrepo/results.

elfs.sh has also been modified to work with the new git repository and is now used throughout the refined build notes.

## Requirements
Some requirements that ELFS assumes are avaible:
- Fedora 38
- Mock >= 4.1
- rpm-build >= 4.18.1
- rpmdevtools >= 9.6
- patch >= 2.7.6
- diffutils >= 3.9
- bash >= 5.2.15

## About Bug Reports
If you cannot reproduce an ELFS build please file a bug report. It is crucial to make sure ELFS is reproducible for anyone with the above requirements!
