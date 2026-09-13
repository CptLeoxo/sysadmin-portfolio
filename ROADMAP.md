# 🗺️ Systems & Infrastructure Roadmap (2026-2027)

This roadmap tracks my journey.

---

## 🛠 Phase 1: Automation & Configuration (Current -> 20.04.2026)
**Goal:** Transitioning from manual "on-host" changes to code-driven management.

| Objective | Focus Area | Status |
| :--- | :--- | :--- |
| **Ansible Mastery** | Playbooks, Roles, & Idempotency | 🥚 Learning |
| **Advanced Linux** | Kernel tuning & Memory management | 🐣 Improving |
| **Version Control** | GitHub Flow | 🐥 Implementing |
| **SSL Automation** | Let's Encrypt & Certbot automation | 🥚 Planned |

---

## 🧪 Phase 2: CI/CD & Service Delivery (Next 3-6 Months)
**Goal:** Automating the "Life Cycle" of a service from code to production.

* **GitHub Actions:** Automating Terraform linting and Ansible syntax checks.
* **Infrastructure Hardening:** Implementing Fail2Ban, NFTables, and SSH key-only policies via code.
* **Centralized Logging:** Moving from simple monitoring to log aggregation.
* **Scripting Pro:** Developing Python-based API integrations for Zabbix and Proxmox.

---

## ☁️ Phase 3: Scaling & Cloud Orchestration (2027)
**Focus:** Managing "Fleets" of servers rather than individual nodes.

* **Public Cloud:** Terraform providers for **AWS/Azure** to build hybrid-cloud environments.
* **Orchestration:** Deploying a lightweight **K3s (Kubernetes)** cluster for container management.
* **High Availability:** Load balancing with Nginx/Keepalived for zero-downtime services.

---

## 🔒 Security & SRE Standards
I follow a **"Security-First"** approach. My roadmap includes the constant integration of:
* Encrypted Secret Management (HashiCorp Vault).
* Regular Post-Mortems for lab failures.
* Automated Backup & Disaster Recovery testing.

---
*Last Updated: 20 April 2026*
