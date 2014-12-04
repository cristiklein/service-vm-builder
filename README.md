Noise-less VM Builder
=====================
This script attempts to build a minimal service VM image, that features as little noise as possible.

Examples
--------

* Create a new VM:
  
          sudo ./service-vm-builder.sh

* Start the VM using libvirt:
  
          virt-install --name rubis0 --ram 4096 --vcpus=16,maxvcpus=16 --import --os-type=linux --disk=rubis0/tmpcOfLsc.qcow2,format=qcow2 --graphics none --controller=virtio-serial --controller=usb,model=none --serial pty --memballoon virtio
