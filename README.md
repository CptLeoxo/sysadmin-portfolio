# Systems & Infrastructure Lab 🛠️

> **Status:** 🏗️ Under Active Development

This repository serves as a public showcase of my **Infrastructure-as-Code (IaC)** templates, monitoring configurations, and automation assets. My goal is to demonstrate a structured, scalable approach to systems administration, prioritizing **automation, reliability, and security.**

---

### 🛠 Technical Proficiency Matrix

| Domain | Technology & Tools | Implementation Area |
| :--- | :--- | :--- |
| **Virtualization & IaC** | Proxmox, Terraform, Ansible | Cluster Provisioning, OS Configuration |
| **Containers** | Docker, Docker-Compose | Service Stacks, Microservices |
| **Monitoring & ITSM** | Zabbix, Prometheus, GLPI, Zammad | Alerting, Asset Tracking, SLA & Ticketing |
| **Networking & Web** | Cisco, Bind9 (DNS), Nginx, Apache | Routing, DNS Management, Reverse Proxying |
| **Security & VPN** | OpenVPN, Wireguard | Secure Tunnels, Remote Site Connectivity |
| **Systems** | Linux (Debian, Alpine), FreeBSD, OpenBSD | Hardening, Kernel Tuning, Scripting |

👉 **[View my detailed Learning & Infrastructure Roadmap here](./ROADMAP.md)**

---

### 📂 Repository Structure

The lab is organized into logical layers, separating foundational platform provisioning from high-level service delivery.

* **`infrastructure/`** — Provisioning and configuration management.
    * `terraform/` — Modular HCL configurations for Proxmox VM/LXC provisioning.
    * `ansible/` — Playbooks for server hardening and software orchestration.
* **`services/`** — Production-ready workloads.
    * `docker/` — Compose files for infrastructure services (Zammad, GLPI, Nginx).
    * `networking/` — Configuration templates for Bind9, OpenVPN, and Wireguard.
* **`observatory/`** — Monitoring and Visualization.
    * `zabbix/` — Sanitized XML/YAML templates and custom discovery scripts.
    * `grafana/` — JSON exports for infrastructure performance dashboards.
* **`scripts/`** — Automation utilities.
    * `bash/` & `python/` — Utilities for system health checks and API integrations.

---

### 🔒 Security Note

All sensitive information (API keys, passwords, private IP addresses) has been externalized using environment variables or placeholder files. No proprietary or copyrighted educational materials are included in this repository.

---
**Maintained by Kai | 2026** *System Administrator | Infrastructure Engineer*
