# https://deepwiki.com/dockur/windows/1.1-getting-started

Requirement	Description	Verification Command
Container Runtime	Docker or Podman installed	docker --version
KVM Support	Hardware virtualization enabled	kvm-ok or check /dev/kvm exists
Storage Space	Minimum 15GB available	df -h
Memory	Minimum 4GB RAM available	free -h
Network	Internet connection for ISO download	ping 8.8.8.8

KVM Acceleration: The container requires access to /dev/kvm for hardware-accelerated virtualization. 
Without KVM, QEMU runs in emulation mode, which is significantly slower. Most Linux systems with 
Intel VT-x or AMD SVM enabled in BIOS support KVM.

Device Access: The container needs access to /dev/kvm and /dev/net/tun. The NET_ADMIN capability 
is required for network configuration. These requirements are included in all deployment examples 
below.