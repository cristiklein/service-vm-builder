Noise-less VM Builder
=====================
This script attempts to build a minimal service VM image, that features as little noise as possible.

Examples
--------

* Create a new VM:
  
          sudo ubuntu-vm-builder qemu trusty -c vmbuilder.cfg --verbose --overwrite

* Start the VM using libvirt:
  
          virt-install --name rubis0 --ram 4096 --vcpus=16,maxvcpus=16 --import --os-type=linux --disk=ubuntu-qemu/tmpcOfLsc.qcow2,format=qcow2 --graphics none --controller=virtio-serial --controller=usb,model=none --serial pty --memballoon virtio
