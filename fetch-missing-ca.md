 fetch-missing-ca

## Purpose

`fetch-missing-ca` is a shell script that helps users analyze and extract the certificate chain (including any missing CA certificates) from a given HTTPS endpoint. It is especially useful for troubleshooting SSL/TLS issues or adding missing CA certificates to your system.

The script:
- Connects to an HTTPS URL and fetches the full certificate chain.
- Extracts each certificate and saves it as a PEM file named after the issuer's CN (Common Name) using a "speaking" algorithm:
  - The first word is used in full.
  - Subsequent words longer than 8 characters are truncated to their first 5 characters; shorter words are kept as-is.
  - All words are concatenated (no spaces), non-alphanumeric characters are removed, and the result is truncated to 40 characters (excluding `.crt`).
  - If no CN is found, a hash-based name is used.
- Prints readable details (subject, issuer, type) for each certificate.
- Optionally generates a Markdown report.
- Saves the certificates as PEM files for inspection or installation.

## Example Usage

```sh
fetch-missing-ca https://dyndns.whatever.com/nic/update
https://dyndns.whatever.com/nic/update
 SectigoPublicServerAutheCAOVR36.crt
  type: Intermediate CA
  subject: C=GB, O=Sectigo Limited,
  subject: CN=Sectigo Public Server Authentication CA OV R36
  issuer: C=GB, O=Sectigo Limited,
  issuer: CN=Sectigo Public Server Authentication Root R46
 Xwhatevercom.crt
  type: End-Entity
  subject: C=DE, ST=Berlin, O=WHATEVER GmbH,
  subject: CN=*.whatever.com
  issuer: C=GB, O=Sectigo Limited,
  issuer: CN=Sectigo Public Server Authentication CA OV R36
```

Or, to generate a Markdown report:
```sh
./fetch-missing-ca -md https://example.com/
```
This creates `Report-example.com.md` with a table of the certificate chain.

#### Naming Algorithm Example

CN: `Sectigo Public Server Authentication CA OV R36`  
Filename: `SectigoPublicServerAutheCAOVR36.crt`

---

## When (and When Not) to Trust a CA Certificate

**Trust a CA certificate only if:**
- It originates from a reputable, well-known Certificate Authority (CA).
- You have verified its fingerprint and issuer using trusted methods.
- It matches documentation or fingerprints published by the CA.
- It is meant to be used for your organization or system.

**Do NOT trust a CA certificate if:**
- The source or issuer is unknown, suspicious, or unverifiable.
- It is self-signed and not cross-signed by a trusted CA, unless you control both ends.
- You cannot independently verify its authenticity.

> **Improperly trusting a CA certificate can expose you to security risks such as man-in-the-middle attacks. Always verify before trusting!**

---

## How to Add a Former Missing CA to Debian Linux

Suppose you've identified a missing CA and want to add it:

### 1. Copy the Certificate

Copy the PEM file (e.g., `SectigoPublicServerAutheCAOVR36.crt`) to the system CA certificates directory:
```sh
sudo cp SectigoPublicServerAutheCAOVR36.crt /usr/local/share/ca-certificates/
```
---
>**ATTENTION**:<br/>
>The PEM file **must** have the suffix .crt in /usr/local/share/ca-certificates/, otherwise the next step **will not** add the certificate to /etc/ssl/certs(/ca-certificates.crt)!
---
### 2. Update the CA Store

Run:
```sh
sudo update-ca-certificates
```

This will:
- Add the new certificate to `/etc/ssl/certs/ca-certificates.crt`
- Make it available to applications using the system CA store.

### 3. Verify Installation

Check the CA is included:
```sh
grep "CN=Sectigo Public Server Authentication CA OV R36" /etc/ssl/certs/ca-certificates.crt
```
Or, verify a server certificate:
```sh
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt server-cert.crt
```

### 4. Remove (if needed)

Delete the PEM file and run:
```sh
sudo update-ca-certificates --fresh
```

---

## Security Notice

**Never add a CA certificate to your trusted store unless you are certain it is legitimate and necessary.**

---

## License and author

This software was created and designed by
Himbeertoni.
Email: Toni.Himbeer@fn.de
Github: https://www.github.com/himbeer-toni

I made extensive use of GitHub Copilot while developing this project. Copilot proved to be incredibly helpful, saving me significant time and enabling me to implement far more features than I could have on my own. It allowed me to easily enhance both the appearance and functionality of the project without requiring extensive manual coding.

This project is licensed under the GNU General Public License v3.0 (GPLv3).

**What does this mean?**  
- You are free to use, study, modify, and share this software.
- If you distribute modified versions, you must also provide the source code and keep them under the same GPLv3 license.
- This ensures that all users have the same freedoms with the software.

For full details, please see the [official GPL v3 license text](https://www.gnu.org/licenses/gpl-3.0.html).

©2025 Himbeertoni

