# fetch-missing-ca

## Purpose

`fetch-missing-ca` is a shell script that helps users analyze and extract the certificate chain (including any missing CA certificates) from a given HTTPS endpoint. It is especially useful for troubleshooting SSL/TLS issues or adding missing CA certificates to your system.

The script:
- Connects to an HTTPS URL and fetches the full certificate chain.
- Extracts each certificate and saves it as a PEM file named after the issuer's CN (Common Name) using a "speaking" algorithm:
  - The first word is used in full.
  - Subsequent words longer than 8 characters are truncated to their first 5 characters; shorter words are kept as-is.
  - All words are concatenated (no spaces), non-alphanumeric characters are removed, and the result is truncated to 40 characters (excluding `.pem`).
  - If no CN is found, a hash-based name is used.
- Prints readable details (subject, issuer, type) for each certificate.
- Optionally generates a Markdown report.
- Saves the certificates as PEM files for inspection or installation.

## Example Usage

```sh
fetch-missing-ca https://dyndns.strato.com/nic/update
https://dyndns.strato.com/nic/update
 SectigoPublicServerAutheCAOVR36.pem
  type: Intermediate CA
  subject: C=GB, O=Sectigo Limited,
  subject: CN=Sectigo Public Server Authentication CA OV R36
  issuer: C=GB, O=Sectigo Limited,
  issuer: CN=Sectigo Public Server Authentication Root R46
 Xstratocom.pem
  type: End-Entity
  subject: C=DE, ST=Berlin, O=STRATO GmbH,
  subject: CN=*.strato.com
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
Filename: `SectigoPublicServerAutheCAOVR36.pem`

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

Copy the PEM file (e.g., `SectigoPublicServerAutheCAOVR36.pem`) to the system CA certificates directory:
```sh
sudo cp SectigoPublicServerAutheCAOVR36.pem /usr/local/share/ca-certificates/
```

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
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt server-cert.pem
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

## License

