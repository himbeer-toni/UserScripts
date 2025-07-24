# fetch-missing-ca

## Purpose

`fetch-missing-ca` is a shell script designed to help users identify, extract, and analyze the certificate chain (including any missing CA certificates) from a specified HTTPS endpoint. Its main purpose is to facilitate troubleshooting SSL/TLS connection issues where a server's certificate chain is incomplete or not trusted by your operating system—particularly useful when you encounter "certificate not trusted" or "unable to get local issuer certificate" errors.

The script:
- Connects to a given HTTPS endpoint and fetches the full certificate chain.
- Extracts each certificate in the chain.
- Prints readable details (subject, issuer, type) for each certificate.
- Optionally generates a Markdown report.
- Saves the certificates as PEM files for further inspection or installation.

## Function

- Uses `openssl s_client` to query the endpoint and retrieve the certificate chain.
- Splits the chain into individual certificates.
- For each certificate, extracts the subject and issuer, and determines if it's a root, intermediate, or leaf (end-entity) certificate.
- Presents details in a user-friendly format, highlighting the CN (Common Name) field for easy identification.
- Outputs certificate files for manual installation if needed.

## Example Usage

```sh
./fetch-missing-ca https://example.com/
```

Example output:
```
https://example.com/
  12345678.pem
   type: Intermediate CA
   subject: C=US, O=Example CA,
      CN=Example Intermediate CA
   issuer: C=US, O=Root CA,
      CN=Example Root CA

  abcd1234.pem
   type: End-Entity
   subject: C=US, O=Example Organization,
      CN=example.com
   issuer: C=US, O=Example CA,
      CN=Example Intermediate CA
```

Or, to generate a Markdown report:
```sh
./fetch-missing-ca -md https://example.com/
```
This will create a report like `Report-example.com.md`.

---

## When (and When Not) to Trust a CA Certificate

**Trust a CA certificate** when:
- It comes from a reputable, well-known Certificate Authority (e.g., Let's Encrypt, DigiCert, Sectigo).
- You have verified its fingerprint and issuer using a trusted method.
- It is distributed by your OS vendor or package manager.
- The certificate details (subject, issuer, validity, fingerprints) match those published by the CA.

**Do NOT trust a CA certificate** when:
- You received it from an untrusted source (e.g., email, random website).
- The issuer or subject looks suspicious or is unfamiliar.
- There is no public documentation or reputation for the CA.
- The certificate is self-signed and not cross-signed by a trusted CA (unless you control both ends).
- You cannot independently verify its authenticity via other channels.

> **Always validate the CA's legitimacy before adding it to your trusted store! Improperly trusting a certificate authority can expose you to man-in-the-middle attacks.**

---

## How to Add a Former Missing CA to Debian Linux

Suppose you've identified a missing intermediate or root CA and want to add it to your system:

### 1. Copy the Certificate

Copy the PEM file (e.g., `ExampleRootCA.pem`) to the system CA certificates directory:
```sh
sudo cp ExampleRootCA.pem /usr/local/share/ca-certificates/
```
or (for older Debian versions):
```sh
sudo cp ExampleRootCA.pem /usr/share/ca-certificates/extra/
```

### 2. Update the CA Store

Run the following command to update your system's CA certificates:
```sh
sudo update-ca-certificates
```

This process will:
- Add the new certificate to `/etc/ssl/certs/ca-certificates.crt`
- Make it available to all applications using the system CA store.

### 3. Verify Installation

You can verify the certificate is included:
```sh
grep "CN=Example Root CA" /etc/ssl/certs/ca-certificates.crt
```
Or, use `openssl`:
```sh
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt your-server-cert.pem
```

### 4. Remove (if needed)

To remove a CA, delete the PEM file you added and run `sudo update-ca-certificates --fresh`.

---

## Security Warning

**Never add a CA certificate to your trusted store unless you are sure it is legitimate and necessary. Improper trust can compromise your security.**

---

## License and author

This software was created and designed by
Himbeertoni.
Email: Toni.Himbeer@fn.de
Github: https://www.github.com/himbeer-toni

I made extensive use of GitHub Copilot while developing this project. Copilot proved to be incredibly helpful, saving me significant time and enabled me to implement some more features. It allowed me to easily enhance both the appearance and functionality of the project without requiring extensive manual coding.

This project is licensed under the GNU General Public License v3.0 (GPLv3).

**What does this mean?**  
- You are free to use, study, modify, and share this software.
- If you distribute modified versions, you must also provide the source code and keep them under the same GPLv3 license.
- This ensures that all users have the same freedoms with the software.

For full details, please see the [official GPL v3 license text](https://www.gnu.org/licenses/gpl-3.0.html).

©2025 Himbeertoni
