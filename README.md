# WAF Rules

These are my custom WAF (Web Application Firewall) rules for OWASP's ModSecurity.

## 📝 Rules

| **Rule set** | **Description** |
| --- | --- |
| [`100` - GeoIP and IP range blocks](modsecurity/100_REQUEST_GEO_AND_IP_BLOCKS.conf) | Blocks certain geographical locations and IP ranges.<br><br>IP address ranges are defined in [`modsecurity/blocked_ip_ranges.data`](modsecurity/blocked_ip_ranges.data) |
| [`200` - Block AI crawlers](modsecurity/200_REQUEST_BLOCK_AI_CRAWLERS.conf) | Blocks known AI crawlers based off their user-agent. |

## 🤝 License

This repo is licensed with the [MIT License](LICENSE).
