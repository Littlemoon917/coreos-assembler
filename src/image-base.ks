# Currently the coreos-assembler tool is generating
# disk images via Anaconda (inside virt-install).
# This is likely to change in the future; see
# https://github.com/coreos/coreos-assembler/issues/75#issuecomment-421139257
# https://github.com/coreos/fedora-coreos-tracker/issues/18
#
text
lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC
selinux --enforcing
# Ensure the root password is disabled (should be the default)
rootpw --lock --iscrypted locked
# We don't want Anaconda to touch the firewall
firewall --disabled

# Anaconda currently writes out configs for this which we don't want to persist; see below
network --bootproto=dhcp --onboot=on

zerombr
clearpart --initlabel --all

# https://github.com/coreos/fedora-coreos-tracker/issues/18
# See also coreos-growpart.service defined in fedora-coreos-base.yaml
# You can change this partition layout, but note that the `boot` and `root`
# filesystem labels are currently mandatory (they're interpreted by coreos-assembler).
part /boot --size=300 --fstype="xfs" --label=boot
# Note no reflinks for /boot since the bootloader may not understand them
part / --size=3000 --fstype="xfs" --label=root --grow --mkfsoptions="-m reflink=1"

reboot

%post --erroronfail
# In this section, undo any changes to `/etc` that we don't want
# Anaconda to keep.  Note that `gf-anaconda-cleanup` will delete
# everything in `/var` like `/var/lib/systemd/random-seed`.

# Remove any persistent NIC rules generated by udev
rm -vf /etc/udev/rules.d/*persistent-net*.rules
%end
