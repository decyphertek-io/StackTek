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

What Happens During First Boot

    ISO Acquisition: If no ISO exists in /storage, the system downloads the Windows installation media from Microsoft's servers or mirror sites using the logic in mido.sh.
    ISO Preparation: The install.sh module extracts the ISO, injects VirtIO drivers for optimal performance, and customizes the unattend.xml answer file with user credentials.
    QEMU Configuration: Multiple modules configure QEMU arguments for disk, network, display, and CPU.
    Windows Installation: Windows Setup runs automatically using the unattended answer file, installs drivers, and creates the user account (default: Docker/admin).
    readme.md175

Subsequent Boots

On subsequent container starts, the system detects the existing virtual disk in /storage. Boot time is reduced to 30-60 seconds as the full installation process is skipped.

Sources:
readme.md75-85
readme.md125-134
Accessing Windows
Web-Based Viewer

The primary access method during installation and initial setup is the web-based console viewer.

Access URL: http://<host-ip>:8006